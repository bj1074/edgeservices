{{/* vim: set filetype=mustache: */}}
{{/*
PTP container details.
*/}}

{{- define "env.ptp.local" -}}
- name: GNB_CONTAINER_NAME
  value: "{{ .Values.ptp.name }}"
- name: PTP_INTF
  value: "{{ .Values.ptp.ptpIntf }}"
- name: PTP_GM_IP
  value: "{{ .Values.ptp.ptpGmIp }}"
- name: PTP_DREQ_RATE
  value: "{{ .Values.ptp.ptpDreqRate }}"
- name: PTP_SYNC_RATE
  value: "{{ .Values.ptp.ptpSyncRate }}"
{{- end -}}

{{/*
Create host path name for corefiles
*/}}
{{- define "ptp.corehostdirectpath" -}}
{{- $poduniquename := tpl .Values.ptp.PodUniqueName . }}
{{- printf "%s/%s/%s" .Values.defaultcorefilepath $poduniquename .Values.gnbBuildVersion | trunc 63 | trimSuffix "/" }}
{{- end -}}

{{/*
Volume for corefile
*/}}
{{- define "ptp.coreVolume" -}}
- name: {{ .Values.ptp.coreVolume }}
  hostPath:
     path: {{ include "ptp.corehostdirectpath" . }}
{{- end }}

{{/*
Volume for UDS (/var/run/ptp4l)
*/}}
{{- define "ptp.varrunVolume" -}}
- name: {{ .Values.podVarRunVolumeMount }}
  hostPath:
     path: /var/run/
{{- end }}

{{- define "container.ptp" -}}
- name: {{ .Values.ptp.name }}
  image: "{{ .Values.ptp.image.repository | default .Values.image.repository }}{{ .Values.ptp.image.image }}:{{ .Values.ptp.image.tag | default .Values.image.tag }}"
  imagePullPolicy: {{ .Values.ptp.image.pullPolicy }}
  volumeMounts:
  - mountPath: {{ .Values.defaultcorefilepath }}
    name: {{ .Values.ptp.coreVolume }}
    readOnly: false
  - mountPath: /var/run/
    name: {{ .Values.podVarRunVolumeMount }}
    readOnly: false
  securityContext:
    {{- toYaml .Values.ptp.securityContext | nindent 4 }}
  resources:
    {{- toYaml .Values.ptp.resources | nindent 4 }}
  command: ["/usr/bin/run_ptp.sh"]
  args: []
  env:
  {{- include "env.ptp.local" . | nindent 4 }}
{{- end }}
