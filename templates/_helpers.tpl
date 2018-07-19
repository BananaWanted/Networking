{{- define "GetConfig" -}}
  {{- $key := index . 0 -}}
  {{- $app_config := index . 1 -}}
  {{- $global := index . 2 -}}
  {{- if hasKey $app_config $key -}}
    {{- index $app_config $key -}}
  {{- else -}}
    {{- index $global.Values.defaultConfig $key -}}
  {{- end -}}
{{- end -}}
