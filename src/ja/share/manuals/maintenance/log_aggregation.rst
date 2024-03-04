==========
ログの集約
==========

| 本説明では Exastro IT Automation の各コンテナのログを集約する(Kubernetes環境における)手段の例を以下に記載します。

コンテナログについて
====================

| Exastroシステムでは、各コンテナのログ出力を標準出力で行っております。（`The Twelve-Factor App <https://12factor.net/ja/logs>`_ の思想に基づく)
| 標準出力されたログは、Kubernetes環境の場合、コンテナがリスタートされたりすると標準出力されたログは削除されてしまいます、そのため、出力されたログを保存するには、その内容を別途保存する必要があります。
| またKubernetes環境における、複数ノードで実行している場合は、その情報が各ノードに保存されているために、監視アプリケーションで監視する際に非常に扱いにくいものとなっております。

| よって本説明では、監視アプリケーション等でも利用しやすいように、ノードごとに出力されたログを集約し、かつ、ファイル形式を :kb:`JSON形式` で出力する方法の一例をあげたいと思います。

.. note::
   | Kubernetesにおけるロギングのアーキテクチャについては、
   | https://kubernetes.io/ja/docs/concepts/cluster-administration/logging/ を参照してください。

ログの集約方法
==============

| 本説明において、ログの集約方法に :kbd:`fluentbit` を使用して、ログの集約を実施する例を説明します。

Fluentbitインストール
---------------------

| Fluentbitのインストールは、公式サイトに基づき、Helm charts を利用してインストールします。
| 公式サイト: `Fluent Bit: Offcial Manual <https://docs.fluentbit.io/manual/installation/kubernetes>`_

前提条件
--------

| 本説明で使用する環境の前提条件は以下の通りとなります。

- | 使用する :kbd:`helm cli` は事前にインストールされていること
- | 出力先のNFSサーバーとKubernetesが動作するサーバー間は、接続できる状態となっていること
- | ログの集約先となるNFSサーバーのディレクトリは :kbd:`/var/PersistentVolume/ha-conf-k8s/exastro-logs` とし、アクセス権がフルアクセスとなっていること

事前準備
--------

| ログを集約するために、今回はNFSを用いた方法とし、出力先にKubernetesの永続ボリューム(PersistentVolume)を利用します。

永続ボリューム(PersistentVolume)の準備
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
| 事前準備として、出力先の永続ボリューム(PV)とリソースの要求(PVC)のmanifestを作成します。

.. code-block:: yaml
   :linenos:
   :caption: fluentbit-pv.yaml

   apiVersion: v1
   kind: PersistentVolumeClaim
   metadata:
     name: pvc-exastro-logs
   spec:
     accessModes:
       - "ReadWriteMany"
     resources:
       requests:
         storage: "10Gi"
     storageClassName: ""
     # volumeName: pv-exastro-logs
   ---
   apiVersion: v1
   kind: PersistentVolume
   metadata:
     name: pv-exastro-logs
   spec:
     capacity:
       storage: 20Gi
     accessModes:
       - ReadWriteMany
     persistentVolumeReclaimPolicy: Retain
     storageClassName: ""
     nfs:
       server: 192.168.172.1
       path: /var/PersistentVolume/ha-conf-k8s/exastro-logs
     claimRef:
       name: pvc-exastro-logs
       namespace: default

fluentbit helm chart values.yamlの準備
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

| helm chartsでインストールする際に使用する`values.yaml`は、以下のコマンドで抽出して、編集する

.. code-block:: shell
   :linenos:
   :caption: コマンド

   helm show values fluent/fluent-bit > fluentbit-values.yaml

.. tip::
   | fluentbitのhelmリポジトリ登録は以下のコマンドで実施できます。 :kbd:`helm show values` を実行する前に１度だけ必要となります。

   .. code-block:: shell
      :linenos:
      :caption: コマンド

      # Exastro システムの Helm リポジトリを登録
      helm repo add fluent https://fluent.github.io/helm-charts
      # リポジトリ情報の更新
      helm repo update

| 出力された :kbd:`fluentbit-values.yaml` を以下のように修正します。

.. code-block:: yaml
   :linenos:
   :caption: fluentbit-values.yaml

   # Default values for fluent-bit.

   # kind -- DaemonSet or Deployment
   kind: DaemonSet

   # replicaCount -- Only applicable if kind=Deployment
   replicaCount: 1

   image:
     repository: cr.fluentbit.io/fluent/fluent-bit
     # Overrides the image tag whose default is {{ .Chart.AppVersion }}
     # Set to "-" to not use the default value
     tag:
     digest:
     pullPolicy: Always

   testFramework:
     enabled: true
     namespace:
     image:
       repository: busybox
       pullPolicy: Always
       tag: latest
       digest:

   imagePullSecrets: []
   nameOverride: ""
   fullnameOverride: ""

   serviceAccount:
     create: true
     annotations: {}
     name:

   rbac:
     create: true
     nodeAccess: false
     eventsAccess: false

   # Configure podsecuritypolicy
   # Ref: https://kubernetes.io/docs/concepts/policy/pod-security-policy/
   # from Kubernetes 1.25, PSP is deprecated
   # See: https://kubernetes.io/blog/2022/08/23/kubernetes-v1-25-release/#pod-security-changes
   # We automatically disable PSP if Kubernetes version is 1.25 or higher
   podSecurityPolicy:
     create: false
     annotations: {}

   # OpenShift-specific configuration
   openShift:
     enabled: false
     securityContextConstraints:
       # Create SCC for Fluent-bit and allow use it
       create: true
       name: ""
       annotations: {}
       # Use existing SCC in cluster, rather then create new one
       existingName: ""

   podSecurityContext: {}
   #   fsGroup: 2000

   hostNetwork: false
   dnsPolicy: ClusterFirst

   dnsConfig: {}
   #   nameservers:
   #     - 1.2.3.4
   #   searches:
   #     - ns1.svc.cluster-domain.example
   #     - my.dns.search.suffix
   #   options:
   #     - name: ndots
   #       value: "2"
   #     - name: edns0

   hostAliases: []
   #   - ip: "1.2.3.4"
   #     hostnames:
   #     - "foo.local"
   #     - "bar.local"

   securityContext: {}
   #   capabilities:
   #     drop:
   #     - ALL
   #   readOnlyRootFilesystem: true
   #   runAsNonRoot: true
   #   runAsUser: 1000

   service:
     type: ClusterIP
     port: 2020
     loadBalancerClass:
     loadBalancerSourceRanges: []
     labels: {}
     # nodePort: 30020
     # clusterIP: 172.16.10.1
     annotations: {}
   #   prometheus.io/path: "/api/v1/metrics/prometheus"
   #   prometheus.io/port: "2020"
   #   prometheus.io/scrape: "true"

   serviceMonitor:
     enabled: false
     #   namespace: monitoring
     #   interval: 10s
     #   scrapeTimeout: 10s
     #   selector:
     #    prometheus: my-prometheus
     #  ## metric relabel configs to apply to samples before ingestion.
     #  ##
     #  metricRelabelings:
     #    - sourceLabels: [__meta_kubernetes_service_label_cluster]
     #      targetLabel: cluster
     #      regex: (.*)
     #      replacement: ${1}
     #      action: replace
     #  ## relabel configs to apply to samples after ingestion.
     #  ##
     #  relabelings:
     #    - sourceLabels: [__meta_kubernetes_pod_node_name]
     #      separator: ;
     #      regex: ^(.*)$
     #      targetLabel: nodename
     #      replacement: $1
     #      action: replace
     #  scheme: ""
     #  tlsConfig: {}

     ## Beare in mind if youn want to collec metrics from a different port
     ## you will need to configure the new ports on the extraPorts property.
     additionalEndpoints: []
     # - port: metrics
     #   path: /metrics
     #   interval: 10s
     #   scrapeTimeout: 10s
     #   scheme: ""
     #   tlsConfig: {}
     #   # metric relabel configs to apply to samples before ingestion.
     #   #
     #   metricRelabelings:
     #     - sourceLabels: [__meta_kubernetes_service_label_cluster]
     #       targetLabel: cluster
     #       regex: (.*)
     #       replacement: ${1}
     #       action: replace
     #   # relabel configs to apply to samples after ingestion.
     #   #
     #   relabelings:
     #     - sourceLabels: [__meta_kubernetes_pod_node_name]
     #       separator: ;
     #       regex: ^(.*)$
     #       targetLabel: nodename
     #       replacement: $1
     #       action: replace

   prometheusRule:
     enabled: false
   #   namespace: ""
   #   additionalLabels: {}
   #   rules:
   #   - alert: NoOutputBytesProcessed
   #     expr: rate(fluentbit_output_proc_bytes_total[5m]) == 0
   #     annotations:
   #       message: |
   #         Fluent Bit instance {{ $labels.instance }}'s output plugin {{ $labels.name }} has not processed any
   #         bytes for at least 15 minutes.
   #       summary: No Output Bytes Processed
   #     for: 15m
   #     labels:
   #       severity: critical

   dashboards:
     enabled: false
     labelKey: grafana_dashboard
     labelValue: 1
     annotations: {}
     namespace: ""

   lifecycle: {}
   #   preStop:
   #     exec:
   #       command: ["/bin/sh", "-c", "sleep 20"]

   livenessProbe:
     httpGet:
       path: /
       port: http

   readinessProbe:
     httpGet:
       path: /api/v1/health
       port: http

   resources: {}
   #   limits:
   #     cpu: 100m
   #     memory: 128Mi
   #   requests:
   #     cpu: 100m
   #     memory: 128Mi

   ## only available if kind is Deployment
   ingress:
     enabled: false
     ingressClassName: ""
     annotations: {}
     #  kubernetes.io/ingress.class: nginx
     #  kubernetes.io/tls-acme: "true"
     hosts: []
     # - host: fluent-bit.example.tld
     extraHosts: []
     # - host: fluent-bit-extra.example.tld
     ## specify extraPort number
     #   port: 5170
     tls: []
     #  - secretName: fluent-bit-example-tld
     #    hosts:
     #      - fluent-bit.example.tld

   ## only available if kind is Deployment
   autoscaling:
     vpa:
       enabled: false

       annotations: {}

       # List of resources that the vertical pod autoscaler can control. Defaults to cpu and memory
       controlledResources: []

       # Define the max allowed resources for the pod
       maxAllowed: {}
       # cpu: 200m
       # memory: 100Mi
       # Define the min allowed resources for the pod
       minAllowed: {}
       # cpu: 200m
       # memory: 100Mi

       updatePolicy:
         # Specifies whether recommended updates are applied when a Pod is started and whether recommended updates
         # are applied during the life of a Pod. Possible values are "Off", "Initial", "Recreate", and "Auto".
         updateMode: Auto

     enabled: false
     minReplicas: 1
     maxReplicas: 3
     targetCPUUtilizationPercentage: 75
     #  targetMemoryUtilizationPercentage: 75
     ## see https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/#autoscaling-on-multiple-metrics-and-custom-metrics
     customRules: []
     #     - type: Pods
     #       pods:
     #         metric:
     #           name: packets-per-second
     #         target:
     #           type: AverageValue
     #           averageValue: 1k
     ## see https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#support-for-configurable-scaling-behavior
     behavior: {}
   #      scaleDown:
   #        policies:
   #          - type: Pods
   #            value: 4
   #            periodSeconds: 60
   #          - type: Percent
   #            value: 10
   #            periodSeconds: 60

   ## only available if kind is Deployment
   podDisruptionBudget:
     enabled: false
     annotations: {}
     maxUnavailable: "30%"

   nodeSelector: {}

   tolerations: []

   affinity: {}

   labels: {}

   annotations: {}

   podAnnotations: {}

   podLabels: {}

   ## How long (in seconds) a pods needs to be stable before progressing the deployment
   ##
   minReadySeconds:

   ## How long (in seconds) a pod may take to exit (useful with lifecycle hooks to ensure lb deregistration is done)
   ##
   terminationGracePeriodSeconds:

   priorityClassName: ""

   # env: []
   #  - name: FOO
   #    value: "bar"
   env:
     - name: TZ
       value: "Asia/Tokyo"

   # The envWithTpl array below has the same usage as "env", but is using the tpl function to support templatable string.
   # This can be useful when you want to pass dynamic values to the Chart using the helm argument "--set <variable>=<value>"
   # https://helm.sh/docs/howto/charts_tips_and_tricks/#using-the-tpl-function
   envWithTpl: []
   #  - name: FOO_2
   #    value: "{{ .Values.foo2 }}"
   #
   # foo2: bar2

   envFrom: []

   extraContainers: []
   #   - name: do-something
   #     image: busybox
   #     command: ['do', 'something']

   flush: 1

   metricsPort: 2020

   extraPorts: []
   #   - port: 5170
   #     containerPort: 5170
   #     protocol: TCP
   #     name: tcp
   #     nodePort: 30517

   extraVolumes:
     - name: volume-exastro-logs
       persistentVolumeClaim:
         claimName: pvc-exastro-logs

   extraVolumeMounts:
     - name: volume-exastro-logs
       mountPath: /var/logs/fluentbit

   updateStrategy: {}
   #   type: RollingUpdate
   #   rollingUpdate:
   #     maxUnavailable: 1

   # Make use of a pre-defined configmap instead of the one templated here
   existingConfigMap: ""

   networkPolicy:
     enabled: false
   #   ingress:
   #     from: []

   # luaScripts: {}
   luaScripts:
     record_date.lua: |
       function record_date(tag, timestamp, record)
               new_record = record
               new_record["record_date"] = os.date("%Y%m%d",timestamp)
               return 1, timestamp, new_record
       end  

   ## https://docs.fluentbit.io/manual/administration/configuring-fluent-bit/classic-mode/configuration-file
   config:
     service: |
       [SERVICE]
           Daemon Off
           Flush {{ .Values.flush }}
           Log_Level {{ .Values.logLevel }}
           Parsers_File /fluent-bit/etc/parsers.conf
           Parsers_File /fluent-bit/etc/conf/custom_parsers.conf
           HTTP_Server On
           HTTP_Listen 0.0.0.0
           HTTP_Port {{ .Values.metricsPort }}
           Health_Check On

     ## https://docs.fluentbit.io/manual/pipeline/inputs
     inputs: |
       [INPUT]
           Name             tail
           Path             /var/log/containers/*.log
           Parser           docker_no_time
           Tag              kube.<namespace_name>.<container_name>
           Tag_Regex        (?<pod_name>[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*)_(?<namespace_name>[^_]+)_(?<container_name>.+)-
           Refresh_Interval 5
           Mem_Buf_Limit    5MB
           Skip_Long_Lines  On

     ## https://docs.fluentbit.io/manual/pipeline/filters
     filters: |
       [FILTER]
           Name                kubernetes
           Match               kube.exastro.*
           Merge_Log           On
           Keep_Log            Off
           K8S-Logging.Parser  On
           K8S-Logging.Exclude On

       [FILTER]
           Name                lua
           Match               kube.exastro.*
           # full path to the script
           script              /fluent-bit/scripts/record_date.lua
           call                record_date

       [FILTER]
           Name                rewrite_tag
           Match               kube.exastro.*
           Rule                $record_date   ^(.*)$  $record_date.$TAG.log false
           Emitter_Name        re_emitted

     ## https://docs.fluentbit.io/manual/pipeline/outputs
     outputs: |
       [OUTPUT]
           Name    file
           Format  plain
           Match   *.kube.exastro.*
           Path    /var/logs/fluentbit/

     ## https://docs.fluentbit.io/manual/administration/configuring-fluent-bit/classic-mode/upstream-servers
     ## This configuration is deprecated, please use `extraFiles` instead.
     upstream: {}

     ## https://docs.fluentbit.io/manual/pipeline/parsers
     customParsers: |
       [PARSER]
           Name        docker_no_time
           # Format      json
           # Time_Keep   Off
           # Time_Key    time
           # Time_Format %Y-%m-%dT%H:%M:%S.%L
           Format      regex
           Regex       ^(?<time>[^ ]+) (?<stream>stdout|stderr) (?<logtag>[^ ]*) (?<log>.*)$
           Time_Keep   Off
           Time_Key    time
           Time_Format %Y-%m-%dT%H:%M:%S.%L%z

     # This allows adding more files with arbitary filenames to /fluent-bit/etc/conf by providing key/value pairs.
     # The key becomes the filename, the value becomes the file content.
     extraFiles: {}
   #     upstream.conf: |
   #       [UPSTREAM]
   #           upstream1
   #
   #       [NODE]
   #           name       node-1
   #           host       127.0.0.1
   #           port       43000
   #     example.conf: |
   #       [OUTPUT]
   #           Name example
   #           Match foo.*
   #           Host bar

   # The config volume is mounted by default, either to the existingConfigMap value, or the default of "fluent-bit.fullname"
   volumeMounts:
     - name: config
       mountPath: /fluent-bit/etc/conf

   daemonSetVolumes:
     - name: varlog
       hostPath:
         path: /var/log
     - name: varlibdockercontainers
       hostPath:
         path: /var/lib/docker/containers
     - name: etcmachineid
       hostPath:
         path: /etc/machine-id
         type: File

   daemonSetVolumeMounts:
     - name: varlog
       mountPath: /var/log
     - name: varlibdockercontainers
       mountPath: /var/lib/docker/containers
       readOnly: true
     - name: etcmachineid
       mountPath: /etc/machine-id
       readOnly: true

   command:
     - /fluent-bit/bin/fluent-bit

   args:
     - --workdir=/fluent-bit/etc
     - --config=/fluent-bit/etc/conf/fluent-bit.conf

   # This supports either a structured array or a templatable string
   initContainers: []

   # Array mode
   # initContainers:
   #   - name: do-something
   #     image: bitnami/kubectl:1.22
   #     command: ['kubectl', 'version']

   # String mode
   # initContainers: |-
   #   - name: do-something
   #     image: bitnami/kubectl:{{ .Capabilities.KubeVersion.Major }}.{{ .Capabilities.KubeVersion.Minor }}
   #     command: ['kubectl', 'version']

   logLevel: info

   hotReload:
     enabled: false
     image:
       repository: ghcr.io/jimmidyson/configmap-reload
       tag: v0.11.1
       digest:
       pullPolicy: IfNotPresent
     resources: {}

.. note::

   | :kbd:`helm show values` で出力された内容をそのまま使用しているため、コメント化された内容もそのまま記載しています。

.. note::

   | ログファイルは、:kbd:`json形式` で出力されるように設定しています。
   | ログファイル名は、ログローテーションを考慮して、日付＋コンテナ名(namespace名含む)で出力されるように設定しています。

.. danger::

   | :kbd:`rewrite_tag` で、rewrite先が同じタグを継承すると永久ループとなり、サーバーが不安定になるので、rewriteのタグは違う内容となるように設定してください。

インストール
------------

| helmによるインストール手順は公式の手順に従ってインストールします。  

.. note::
   | 公式の手順のまま実施しているため、namespaceは指定しておりません。

- | PV, PVCのapply

  .. code-block:: shell
     :caption: コマンド

     kubectl apply -f fluentbit-pv.yaml


- | fluentbit install

  .. code-block:: shell
     :caption: コマンド

     helm upgrade --install fluent-bit fluent/fluent-bit -f fluentbit-values.yaml

- | インストールされた :kbd:`fluent bit` の確認

  .. code-block:: shell
     :caption: コマンド

     kubectl get po

  .. code-block:: shell
     :caption: 実行結果

     NAME               READY   STATUS              RESTARTS   AGE
     fluent-bit-gx2c5   1/1     Running             0          22s
     fluent-bit-tgbls   0/1     ContainerCreating   0          22s
     fluent-bit-xhm6w   0/1     ContainerCreating   0          22s

  .. code-block:: shell
     :caption: コマンド

     kubectl get daemonset

  .. code-block:: shell
     :caption: 実行結果

     NAME         DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
     fluent-bit   3         3         3       3            3           <none>          88m

出力された内容を確認
--------------------

| インストール完了後、すぐに設定された内容で、NFSサーバーにログファイルが集約されます。

- | 集約したログファイル一覧(例)

  .. code-block:: shell
     :caption: 実行結果

     ll
     total 8144
     -rw-r--r-- 1 root root   21448 Feb 29 16:57 kube.exastro.20240229.kube.exastro.ita-by-ansible-execute.log
     -rw-r--r-- 1 root root   26553 Feb 29 16:57 kube.exastro.20240229.kube.exastro.ita-by-ansible-legacy-role-vars-listup.log
     -rw-r--r-- 1 root root   23379 Feb 29 16:57 kube.exastro.20240229.kube.exastro.ita-by-ansible-legacy-vars-listup.log
     -rw-r--r-- 1 root root   26553 Feb 29 16:57 kube.exastro.20240229.kube.exastro.ita-by-ansible-pioneer-vars-listup.log
     -rw-r--r-- 1 root root   26553 Feb 29 16:57 kube.exastro.20240229.kube.exastro.ita-by-ansible-towermaster-sync.log
     -rw-r--r-- 1 root root   26553 Feb 29 16:57 kube.exastro.20240229.kube.exastro.ita-by-cicd-for-iac.log
     -rw-r--r-- 1 root root   23379 Feb 29 16:57 kube.exastro.20240229.kube.exastro.ita-by-collector.log
     -rw-r--r-- 1 root root   29727 Feb 29 16:57 kube.exastro.20240229.kube.exastro.ita-by-conductor-regularly.log
     -rw-r--r-- 1 root root   26553 Feb 29 16:57 kube.exastro.20240229.kube.exastro.ita-by-conductor-synchronize.log
     -rw-r--r-- 1 root root   26553 Feb 29 16:57 kube.exastro.20240229.kube.exastro.ita-by-excel-export-import.log
     -rw-r--r-- 1 root root   26553 Feb 29 16:57 kube.exastro.20240229.kube.exastro.ita-by-hostgroup-split.log
     -rw-r--r-- 1 root root   26553 Feb 29 16:57 kube.exastro.20240229.kube.exastro.ita-by-menu-create.log
     -rw-r--r-- 1 root root   26553 Feb 29 16:57 kube.exastro.20240229.kube.exastro.ita-by-menu-export-import.log
     -rw-r--r-- 1 root root  854127 Feb 29 17:05 kube.exastro.20240229.kube.exastro.ita-by-oase-conclusion.log
     -rw-r--r-- 1 root root   23379 Feb 29 16:57 kube.exastro.20240229.kube.exastro.ita-by-terraform-cli-execute.log
     -rw-r--r-- 1 root root   26553 Feb 29 16:57 kube.exastro.20240229.kube.exastro.ita-by-terraform-cli-vars-listup.log
     -rw-r--r-- 1 root root   23379 Feb 29 16:57 kube.exastro.20240229.kube.exastro.ita-by-terraform-cloud-ep-execute.log
     -rw-r--r-- 1 root root   29727 Feb 29 16:57 kube.exastro.20240229.kube.exastro.ita-by-terraform-cloud-ep-vars-listup.log
     -rw-r--r-- 1 root root   36214 Feb 29 16:57 kube.exastro.20240229.kube.exastro.keycloak.log
     -rw-r--r-- 1 root root  326218 Feb 29 17:05 kube.exastro.20240229.kube.exastro.mariadb.log
     -rw-r--r-- 1 root root 3632177 Feb 29 17:05 kube.exastro.20240229.kube.exastro.mongo.log
     -rw-r--r-- 1 root root 2691437 Feb 29 17:05 kube.exastro.20240229.kube.exastro.platform-api.log
     -rw-r--r-- 1 root root    1703 Feb 29 15:23 kube.exastro.20240229.kube.exastro.platform-auth.log
     -rw-r--r-- 1 root root  288678 Feb 29 17:03 kube.exastro.20240229.kube.exastro.platform-job.log
     -rw-r--r-- 1 root root     198 Feb 29 16:57 kube.exastro.20240229.kube.exastro.remove-data.log

- | 集約したログファイルの内容(例)

  .. code-block:: json
     :caption: 集約したログファイルの内容

     {"stream":"stdout","logtag":"F","record_date":"20240301","log":"2024/03/01 16:40:09.098836 INFO (dumm) /app/controllers/internal_maintenance_mode_setting_controller.py(37) ### func:internal_get_maintenance_mode_setting"}
     {"stream":"stdout","logtag":"F","record_date":"20240301","log":"192.168.172.2 - - [01/Mar/2024:16:40:09 +0900] \"GET /internal-api/platform/maintenance-mode-setting HTTP/1.1\" 200 135 \"-\" \"python-requests/2.31.0\""}
     {"stream":"stdout","logtag":"F","record_date":"20240301","log":"192.168.172.2 - - [01/Mar/2024:16:40:09 +0900] \"GET /internal-api/platform/maintenance-mode-setting HTTP/1.1\" 200 135"}
     {"stream":"stdout","logtag":"F","record_date":"20240301","log":"2024/03/01 16:40:10.666816 INFO (dumm) /app/controllers/internal_maintenance_mode_setting_controller.py(37) ### func:internal_get_maintenance_mode_setting"}
     {"stream":"stdout","logtag":"F","record_date":"20240301","log":"192.168.172.2 - - [01/Mar/2024:16:40:10 +0900] \"GET /internal-api/platform/maintenance-mode-setting HTTP/1.1\" 200 135 \"-\" \"python-requests/2.31.0\""}
     {"stream":"stdout","logtag":"F","record_date":"20240301","log":"192.168.172.2 - - [01/Mar/2024:16:40:10 +0900] \"GET /internal-api/platform/maintenance-mode-setting HTTP/1.1\" 200 135"}
     {"stream":"stdout","logtag":"F","record_date":"20240301","log":"2024/03/01 16:40:12.326828 INFO (dumm) /app/controllers/internal_maintenance_mode_setting_controller.py(37) ### func:internal_get_maintenance_mode_setting"}
     {"stream":"stdout","logtag":"F","record_date":"20240301","log":"192.168.172.2 - - [01/Mar/2024:16:40:12 +0900] \"GET /internal-api/platform/maintenance-mode-setting HTTP/1.1\" 200 135 \"-\" \"python-requests/2.31.0\""}
     {"stream":"stdout","logtag":"F","record_date":"20240301","log":"192.168.172.2 - - [01/Mar/2024:16:40:12 +0900] \"GET /internal-api/platform/maintenance-mode-setting HTTP/1.1\" 200 135"}
     {"stream":"stdout","logtag":"F","record_date":"20240301","log":"2024/03/01 16:40:12.807144 INFO (dumm) /app/controllers/internal_maintenance_mode_setting_controller.py(37) ### func:internal_get_maintenance_mode_setting"}
     {"stream":"stdout","logtag":"F","record_date":"20240301","log":"192.168.172.2 - - [01/Mar/2024:16:40:12 +0900] \"GET /internal-api/platform/maintenance-mode-setting HTTP/1.1\" 200 135 \"-\" \"python-requests/2.31.0\""}
     {"stream":"stdout","logtag":"F","record_date":"20240301","log":"192.168.172.2 - - [01/Mar/2024:16:40:12 +0900] \"GET /internal-api/platform/maintenance-mode-setting HTTP/1.1\" 200 135"}
     {"stream":"stdout","logtag":"F","record_date":"20240301","log":"2024/03/01 16:40:12.836383 INFO (dumm) /app/controllers/internal_common_service_controller.py(153) ### func:internal_settings_system_config_list"}
     {"stream":"stdout","logtag":"F","record_date":"20240301","log":"192.168.172.2 - - [01/Mar/2024:16:40:12 +0900] \"GET /internal-api/platform/settings/common HTTP/1.1\" 200 223 \"-\" \"python-requests/2.31.0\""}
     {"stream":"stdout","logtag":"F","record_date":"20240301","log":"192.168.172.2 - - [01/Mar/2024:16:40:12 +0900] \"GET /internal-api/platform/settings/common HTTP/1.1\" 200 223"}
     {"stream":"stdout","logtag":"F","record_date":"20240301","log":"2024/03/01 16:40:12.858139 INFO (dumm) /app/controllers/internal_plan_service_controller.py(62) ### func:limits_get"}
     {"stream":"stdout","logtag":"F","record_date":"20240301","log":"192.168.172.2 - - [01/Mar/2024:16:40:12 +0900] \"GET /internal-api/platform/limits HTTP/1.1\" 200 239 \"-\" \"python-requests/2.31.0\""}
     {"stream":"stdout","logtag":"F","record_date":"20240301","log":"192.168.172.2 - - [01/Mar/2024:16:40:12 +0900] \"GET /internal-api/platform/limits HTTP/1.1\" 200 239"}
     {"stream":"stdout","logtag":"F","record_date":"20240301","log":"2024/03/01 16:40:15.921191 INFO (dumm) /app/controllers/internal_maintenance_mode_setting_controller.py(37) ### func:internal_get_maintenance_mode_setting"}

.. note::
   | 本説明では、ログファイルのローテーションに関する説明は行っておりません。
   | 出力先の容量（ディスクサイズ）に合わせて、ログファイルのローテーションを行うことをお勧めします。

