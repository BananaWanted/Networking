{{- define "GetValueByPath" -}}
  {{- $obj := index $ 0 -}}
  {{- $keys := index $ 1 -}}
  {{- if $keys -}}
    {{- $key := first $keys -}}
    {{- if kindIs "map" $obj -}}
      {{- if hasKey $obj $key -}}
        {{- $next_obj := index $obj $key -}}
        {{- include "GetValue" (list $next_obj (rest $keys)) -}}
      {{- end -}}
    {{- else if kindIs "slice" $obj -}}
      {{- if lt $key (len $obj) -}}
        {{- $next_obj := index $obj $key -}}
        {{- include "GetValue" (list $next_obj (rest $keys)) -}}
      {{- end -}}
    {{- end -}}
  {{- else -}}
    {{- $obj | toJson -}}
  {{- end -}}
{{- end -}}

{{- define "GetValue" -}}
  {{- $obj := index $ 0 -}}
  {{- $keys := index $ 1 -}}
  {{- if kindIs "slice" $keys -}}
    {{- include "GetValueByPath" (list $obj $keys) -}}
  {{- else -}}
    {{- include "GetValueByPath" (list $obj (rest $)) -}}
  {{- end -}}
{{- end -}}

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
