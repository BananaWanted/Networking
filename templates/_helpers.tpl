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
    {{- if $obj -}}
      {{- if or (kindIs "map" $obj) (kindIs "slice" $obj) -}}
        {{- $obj | toJson -}}
      {{- else -}}
        {{- $obj -}}
      {{- end -}}
    {{- end -}}
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

{{- define "GetConfigOld" -}}
  {{- $key := index . 0 -}}
  {{- $app_config := index . 1 -}}
  {{- $global := index . 2 -}}
  {{- if hasKey $app_config $key -}}
  {{- index $app_config $key -}}
  {{- else -}}
  {{- index $global.Values.defaultConfig $key -}}
  {{- end -}}
{{- end -}}

{{- define "GetConfig3" -}}
  {{- $objs := index $ 0 -}}
  {{- $keys := index $ 1 -}}

  {{- range $i, $obj := $objs -}}
    {{- include "GetValue" (list $obj $keys) -}}
    {{- "\n" -}}
  {{- end -}}

  {{/*- coalesce $vals -*/}}
{{- end -}}

{{- define "GetConfig2" -}}
  {{- $objs := index $ 0 -}}
  {{- $keys := index $ 1 -}}
  {{- $first_key := first $keys -}}
  {{- $rest_keys := rest $keys -}}

  {{- if or (kindIs "map" $first_key) (kindIs "slice" $first_key) -}}
    {{- include "GetConfig2" (list (append $objs $first_key) $rest_keys) -}}
  {{- else -}}
    {{- include "GetConfig3" (list $objs $keys) -}}
  {{- end -}}
{{- end -}}

{{- define "GetConfig" -}}
  {{- include "GetConfig2" (list list $) | splitList "\n" | first -}}
{{- end -}}
