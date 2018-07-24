{{- define "Networking.App.Label" -}} {{- /* params: app: String, appConfig: map, globalContext: map */ -}}
{{- $app := index . 0 }}
{{- $appConfig := index . 1 }}
{{- $global := index . 2 }}
{{- $chart := list $global.Chart.Name $global.Chart.Version | join "-" | replace "+" "_" | trunc 63 | trimSuffix "-" }}
app: {{ $app }}
chart: {{ $chart }}
release: {{ $global.Release.Name }}
build: {{ $global.Values.buildTag }}
testing: {{ $global.Values.testing | quote }}
{{- end -}}