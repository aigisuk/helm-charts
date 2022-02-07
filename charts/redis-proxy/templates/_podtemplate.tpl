{{- define "redis-proxy.podTemplate" }}
    metadata:
      labels:
        app.kubernetes.io/name: {{ include "redis-proxy.name" . }}
        app.kubernetes.io/instance: {{ .Release.Name }}
      annotations:
      {{- with .Values.deployment.podAnnotations }}
      {{- toYaml . | nindent 8 }}
      {{- end }}
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          command:
            - socat
          args:
            - "$(ADDRESS_TYPE_SRC):$(ADDRESS_PORT_SRC),$(ADDRESS_OPTIONS_SRC)"
            - "$(ADDRESS_TYPE_DEST):$(ADDRESS_HOST_DEST):$(ADDRESS_PORT_DEST),$(ADDRESS_OPTIONS_DEST)"
          env:
            - name: ADDRESS_TYPE_SRC
              value: {{ required "Must specify source address type for the relay." .Values.source.address.type | quote }}
            - name: ADDRESS_PORT_SRC
              value: {{ required "Must specify source address port for the relay." .Values.source.address.port | quote }}
            - name: ADDRESS_OPTIONS_SRC
              value: {{ join "," .Values.source.address.options }}
            - name: ADDRESS_TYPE_DEST
              value: {{ required "Must specify destination address type for the relay." .Values.destination.address.type | quote }}
            - name: ADDRESS_HOST_DEST
              value: {{ required "Must specify destination address host for the relay." .Values.destination.address.host | quote }}
            - name: ADDRESS_PORT_DEST
              value: {{ required "Must specify destination address port for the relay." .Values.destination.address.port | quote }}
            - name: ADDRESS_OPTIONS_DEST
              value: {{ join "," .Values.destination.address.options }}
          ports:
            - name: redis-port
              containerPort: {{ (int64 .Values.source.address.port) }}
              protocol: TCP
          resources:
          {{- with .Values.resources }}
          {{- toYaml . | nindent 12 }}
          {{- end }}
{{ end -}}