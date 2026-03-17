## CPU Total
```
sum(rate({source="host"} | json cpu="cpu_p" [1m]))
```

## CPU by core
```
avg by (cpu) (avg_over_time({source="host"} | json | unwrap cpu_p [1m]))
```

## Mem Total
```
sum(rate({source="host"} | json mem="mem_p" [1m]))
```

## Mem by Node
```
avg by (node) (rate({source="host"} | json mem="mem_p" [1m]))
```