{job="fluentbit", source="docker"} | json
{job="fluentbit", source="host"} | json

sum(rate({job="fluentbit"} | json cpu="cpu_p" [1m]))

rate({job="fluentbit", source="docker"} |="info" | json name="container_name" | line_format "{{.name}}" [1m])

avg by (cpu) (avg_over_time({job="fluentbit", source="host"} | json | unwrap cpu_p [1m]))