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


{{- define "Networking.App.Env" -}} {{- /* params: envName: String, envValue: Strin, appConfig: map */ -}}
{{- $envName := index . 0 }}
{{- $envValue := index . 1 }}
{{- $appConfig := index . 2 }}
{{- if $appConfig.envPrefix }}
- name: {{ list $appConfig.envPrefix $envName | join "" | quote }}
  value: {{ $envValue | quote }}
{{- end }}
- name: {{ $envName | quote }}
  value: {{ $envValue | quote }}
{{- end -}}


{{- define "Networking.App.SecretEnv" -}} {{- /* params: envName: String, secretName: String, secretKey: String appConfig: map */ -}}
{{- $envName := index . 0 }}
{{- $secretName := index . 1 }}
{{- $secretKey := index . 2 }}
{{- $appConfig := index . 3 }}
{{- if $appConfig.envPrefix }}
- name: {{ list $appConfig.envPrefix $envName | join "" | quote }}
  valueFrom:
    secretKeyRef:
      name: {{ $secretName }}
      key: {{ $secretKey }}
{{- end }}
- name: {{ $envName | quote }}
  valueFrom:
    secretKeyRef:
      name: {{ $secretName }}
      key: {{ $secretKey }}
{{- end -}}


{{- define "Networking.App.EnvSection" -}} {{- /* params: app: String, globalContext: map */ -}}
{{- $app := index . 0 }}
{{- $global := index . 1 }}
{{- $appConfig := index $global.Values.appConfigs $app }}

{{- if or $global.Values.testing $appConfig.envDatabase $appConfig.mountSecrets $appConfig.env }}
env:
  # testing indicator
  {{- if $global.Values.testing }}
    {{- include "Networking.App.Env" (list "TESTING" $global.Values.testing $appConfig) | indent 2 }}
  {{- end }}
  # database settings
  {{- if $appConfig.envDatabase }}
    {{- if $global.Values.testing }}
      {{- $DB_HOST := list $global.Release.Name (default "postgresTesting" $global.Values.postgresTesting.nameOverride) | join "-" }}
      {{- $DB_PORT := $global.Values.postgresTesting.service.port }}
      {{- include "Networking.App.Env" (list "DB_HOST" $DB_HOST $appConfig) | indent 2 }}
      {{- include "Networking.App.Env" (list "DB_PORT" $DB_PORT $appConfig) | indent 2 }}
    {{- else }}
      {{- $DB_HOST := list $global.Release.Name "postgres" | join "-" }}
      {{- $DB_PORT := (index $global.Values.postgres.cloudsql.instances 0).port }}
      {{- include "Networking.App.Env" (list "DB_HOST" $DB_HOST $appConfig) | indent 2 }}
      {{- include "Networking.App.Env" (list "DB_PORT" $DB_PORT $appConfig) | indent 2 }}
    {{- end }}
    {{- include "Networking.App.SecretEnv" (list "DB_USERNAME" $global.Values.databaseSecret "username" $appConfig) | indent 2 }}
    {{- include "Networking.App.SecretEnv" (list "DB_PASSWORD" $global.Values.databaseSecret "password" $appConfig) | indent 2 }}
  {{- end }}
  # additional envs
  {{- if $appConfig.env }}
    {{- range $key, $val := $appConfig.env }}
      {{- include "Networking.App.Env" (list $key $val $appConfig) | indent 2 }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end -}}


{{- define "Networking.App.Volumes" -}} {{- /* params: app: String, globalContext: map */ -}}
{{- $app := index . 0 }}
{{- $global := index . 1 }}
{{- $appConfig := index $global.Values.appConfigs $app }}
{{- if $appConfig.mountSecrets }}
volumes:
  {{- range $i, $secretMount := $appConfig.mountSecrets }}
  - name: {{ list $global.Release.Name "secret" $secretMount.name | join "-" }}
    secret:
      secretName: {{ $secretMount.name }}
  {{- end }}
{{- end }}
{{- end -}}


{{- define "Networking.App.VolumeMounts" -}} {{- /* params: app: String, globalContext: map */ -}}
{{- $app := index . 0 }}
{{- $global := index . 1 }}
{{- $appConfig := index $global.Values.appConfigs $app }}
{{- if $appConfig.mountSecrets }}
volumeMounts:
  {{- range $i, $secretMount := $appConfig.mountSecrets }}
  - name: {{ list $global.Release.Name "secret" $secretMount.name | join "-" }}
    mountPath: {{ $secretMount.path | quote }}
  {{- end }}
{{- end }}
{{- end -}}


{{- define "Networking.App.initContainers" -}} {{- /* params: app: String, globalContext: map */ -}}
{{- $app := index . 0 }}
{{- $global := index . 1 }}
{{- $appConfig := index $global.Values.appConfigs $app }}
  {{- if $appConfig.envDatabase }}
initContainers:
- name: {{ include "Networking.App.DNSName" (list $app $global) }}-wait-for-db
  image: {{ $global.Values.dockerRegistry -}} /
        {{- list "wait-for-db" $global.Values.buildTag | join ":" }}
        {{- if $global.Values.testing -}} -test {{- end }}
  {{- include "Networking.App.EnvSection" (list $app $global) | indent 2 }}
  {{- end }}
{{- end -}}
