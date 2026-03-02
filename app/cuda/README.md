
export PATH=/usr/local/cuda/bin${PATH:+:${PATH}}
export LD_LIBRARY_PATH=/usr/local/cuda/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

### add volume for access to the host's GPU
- driver_11:/usr/local/cuda


```bash
ubuntu-carlj:
    <<: *ubuntu-base
    container_name: "ubuntu-carlj"
    privileged: true
    environment:
      USERNAME: "carlj"
      PSWD: "9031"
    volumes:
      - *vol-shared
      - *vol-tmp
      - *vol-log
      - *vol-cache
      - *vol-opt
      - *vol-conda
      - user_data_carlj:/home/carlj
      - user_cache:/home/carlj/.cache
      - cuda_driver_11:/usr/local/cuda
    
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
```


