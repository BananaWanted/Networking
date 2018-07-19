{{- define "GetConfig" -}}
  {{- $local_config_obj := index . 0 -}}
  {{- $config_key := index . 1 -}}
  {{- (index $local_config_obj $config_key) | default (index $.Values.defaultConfig $config_key) -}}
{{- end -}}
