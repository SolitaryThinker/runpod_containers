# runpod_containers


To build image:

```bash
sudo docker build . -t <tag_name>
```

To push image:
```bash
sudo docker push <image_name>
```

To test locally with automtical removal:
```bash
sudo docker run  --network host -p 8888:8888 -v $(pwd)/src:/workspace/src -v /mnt/:/mnt --gpus all -it --rm wlsaidhi/llm_judge /bin/bash
```

To test locally as daemon:
```bash
sudo docker run  --network host -p 8888:8888 -v $(pwd)/src:/workspace/src -v /mnt/:/mnt --gpus all -it -d wlsaidhi/llm_judge /bin/bash
```
