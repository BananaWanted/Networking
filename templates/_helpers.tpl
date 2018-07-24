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
