## Quantile_over_time by (component)
```
quantile_over_time(0.95,
  {source="docker"} 
    | json 
    | line_format "{{.log}}" 
    | logfmt 
    | regexp "wait_for_lock=(?P<duration_numeric>[0-9\\.]+)"
    | unwrap duration_numeric 
    | __error__="" [1m]
) by (component)
```

## Avg by (component)
```
avg by (component) (
  avg_over_time(
    {source="docker"} 
      | json 
      | line_format "{{.log}}" 
      | logfmt 
      | regexp "wait_for_lock=(?P<lock_numeric>[0-9\\.]+)"
      | unwrap lock_numeric 
      | __error__="" [1m]
  )
)
```

## Sum by (status)
```
sum by (status) (
  count_over_time(
    {source="docker"} | json | line_format "{{.log}}" | logfmt | status != "" [1m]
  )
)
```

## Sum by (level)
```
sum by (level) (
  count_over_time(
    {source="docker"} | json | line_format "{{.log}}" | logfmt [1m]
  )
)
```