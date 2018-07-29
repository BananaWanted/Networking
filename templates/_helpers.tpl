{{- define "Networking.App.DNSName" }} {{- /* params: app: String, globalContext: map */ -}}
{{- $app := index . 0 }}
{{- $global := index . 1 }}
{{- $appConfig := index $global.Values.appConfigs $app }}
{{- list $global.Release.Name (default $app $appConfig.nameOverride) | join "-" }}
{{- end }}

{{- define "Networking.App.Label" -}} {{- /* params: app: String, globalContext: map */ -}}
{{- $app := index . 0 }}
{{- $global := index . 1 }}
{{- $appConfig := index $global.Values.appConfigs $app }}
{{- $chart := list $global.Chart.Name $global.Chart.Version | join "-" | replace "+" "_" | trunc 63 | trimSuffix "-" }}
app: {{ $app }}
chart: {{ $chart }}
release: {{ $global.Release.Name }}
build: {{ $global.Values.buildTag }}
testing: {{ $global.Values.testing | quote }}
{{- end -}}

{{- define "Networking.App.EnvName" -}} {{- /* params: rawEnvName: String, appConfig: map */ -}}
{{- $rawEnvName := index . 0 }}
{{- $appConfig := index . 1 }}
{{- $envPrefix := $appConfig.envPrefix | default "" }}
{{- list $envPrefix $rawEnvName | join "" | quote }}
{{- end -}}

{{- define "Networking.App.EnvSection" -}} {{- /* params: app: String, globalContext: map */ -}}
{{- $app := index . 0 }}
{{- $global := index . 1 }}
{{- $appConfig := index $global.Values.appConfigs $app }}

{{- if or $global.Values.testing $appConfig.envDatabase $appConfig.mountSecrets $appConfig.env }}

env:
  # testing indicator
  {{- if $global.Values.testing }}
  - name: {{ include "Networking.App.EnvName" (list "TESTING" $appConfig) }}
    value: {{ $global.Values.testing | quote }}
  {{ end }}
  # database settings
  {{- if $appConfig.envDatabase }}
    {{- if $global.Values.testing }}
  - name: {{ include "Networking.App.EnvName" (list "DB_HOST" $appConfig) }}
    value: {{ list $global.Release.Name (default "postgresTesting" $global.Values.postgresTesting.nameOverride) | join "-" }}
  - name: {{ include "Networking.App.EnvName" (list "DB_PORT" $appConfig) }}
    value: {{ $global.Values.postgresTesting.service.port | quote }}
    {{- else }}
  - name: {{ include "Networking.App.EnvName" (list "DB_HOST" $appConfig) }}
    value: {{ list $global.Release.Name "postgres" | join "-" }}
  - name: {{ include "Networking.App.EnvName" (list "DB_PORT" $appConfig) }}
    value: {{ (index $global.Values.postgres.cloudsql.instances 0).port | quote }}
    {{- end }}
  - name: {{ include "Networking.App.EnvName" (list "DB_USERNAME" $appConfig) }}
    valueFrom:
      secretKeyRef:
        name: {{ $global.Values.databaseSecret }}
        key: username
  - name: {{ include "Networking.App.EnvName" (list "DB_PASSWORD" $appConfig) }}
    valueFrom:
      secretKeyRef:
        name: {{ $global.Values.databaseSecret }}
        key: password
  {{- end }}
  # additional envs
  {{- if $appConfig.env }}
  {{- range $key, $val := $appConfig.env }}
  - name: {{ include "Networking.App.EnvName" (list $key $appConfig) }}
    value: {{ $val | quote }}
  {{- end }}
  {{- end }}
  # additional raw envs (where ignoring envPrefix setting)
  {{- if $appConfig.env_raw }}
  {{- range $key, $val := $appConfig.env_raw }}
  - name: {{ $key | quote }}
    value: {{ $val | quote }}
  {{- end }}
  {{- end }}

{{- end }}
{{- end -}}