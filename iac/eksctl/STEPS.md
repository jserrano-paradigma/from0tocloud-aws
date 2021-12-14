# Cloudformation stack for EKS

## Generar infra con CloudFormation

1. Crear nuevo role con permisos AmazonEKSClusterPolicy y AmazonEKSServicePolicy
2. Crear stack nuevo subiendo archivo eks-vpc.yaml y dejando todo por defecto
3. Crear cluster de eks ejecutando desde terminal el comando:

    ```sh
    aws eks --region eu-west-1 create-cluster --name from0tocloud-eks-cluster --role-arn arn:aws:iam::129822709161:role/eksrole --resources-vpc-config subnetIds=subnet-057f285f45b061d22,subnet-013a9a9e2e1df0d21,subnet-0f8a0e4648d46abc9,securityGroupIds=sg-0a215c345ba7a9924
    ```

    La ejecución generará la siguiente salida por consola:

    ```sh
    cluster:
        arn: arn:aws:eks:eu-west-1:129822709161:cluster/from0tocloud-eks-cluster
        certificateAuthority: {}
        createdAt: '2021-11-15T19:35:41.387000+01:00'
        kubernetesNetworkConfig:
            serviceIpv4Cidr: 10.100.0.0/16
        logging:
            clusterLogging:
            - enabled: false
            types:
            - api
            - audit
            - authenticator
            - controllerManager
            - scheduler
        name: from0tocloud-eks-cluster
        platformVersion: eks.3
        resourcesVpcConfig:
            endpointPrivateAccess: false
            endpointPublicAccess: true
            publicAccessCidrs:
            - 0.0.0.0/0
            securityGroupIds:
            - sg-03172103751ef74dc
            subnetIds:
            - subnet-051e39c465d8f8184
            - subnet-05150092a296f3d36
            - subnet-0e8298eb64bf3639e
            vpcId: vpc-0c3794c253ec53698
        roleArn: arn:aws:iam::129822709161:role/eksrole
        status: CREATING
        tags: {}
        version: '1.21'
    ```

    _Nota_: Las subnets y el securitygroup son outputs del stack

    Para comprobar el estado de creación del cluster ejecutar el comando:

    ```sh
    aws eks --region eu-west-1 describe-cluster --name from0tocloud-eks-cluster --query cluster.status
    ```

4. Una vez finalizada la creación del cluster (aproximadamente 5-10 minutos) Actualizamos el kubeconfig para interactuar con el cluster cuando se haya terminado de crear, ejecutando el comando

    ```sh
    aws eks --region eu-west-1 update-kubeconfig --name from0tocloud-eks-cluster
    ```

5. Creamos los worker nodes creando un nuevo stack con el archivo eks-nodegroup.yaml y dejando todos los valores por defecto.
   Usaremos los siguientes parámetros:
   - Stack Name: from0tocloud-cf-node-group
   - EKS Cluster:
        - ClusterName: from0tocloud-eks-cluster
        - ClusterControlPlaneSecurityGroup: seleccionar el clusterplane generado en pasos anteriores
   - Worker Node Configuration:
        - NodeGroupName: from0tocloud-eks-cluster-nodes
        - NodeAutoScalingGroupMinSize: 1
        - NodeAutoScalingGroupDesiredCapacity: 3
        - NodeAutoScalingGroupMaxSize: 4
        - NodeInstanceType: t2.micro
        - NodeImageId: ami-063d4ab14480ac177
        - NodeVolumeSize: 20
        - KeyName: from0tocloud-key
    - Worker Network Configuration:
        - VpcId: VPC Creada en pasos anteriores
        - Subnets: Las 3 creadas en los pasos anteriores
    Se avanza en el wizard, en el último paso se marca el checkbox y se crea el stack aproximadamente tarda 5-10 minutos

    * OJO usar este AMI ami-063d4ab14480ac177 es un Amazon Linux para instancia t2.micro.

6. Ahora añadimos los worker nodes al cluster de K8S para esto usaremos el Config MAp de autenticación AWS aws-auth-cm.yaml y lo cargamos ejecutando el comando:

   ```sh
   kubectl apply -f aws-auth-cm.yaml
   ```

   Nos dará como resultado `configmap/aws-auth created`

   Para comprobar los nodos ejecutamos el comando: `kubectl get nodes --watch`

## Usando eksctl

### Cluster AWS Fargate

Para montar el cluster con fargate que es la solución serverless de contenedores hay que ejecutar los siguientes comandos:

```sh
eksctl create cluster --name from0tocloud --region eu-west-1 --fargate
```

Para comprobar que todo es correcto:

```sh
kubectl get svc
kubectl get nodes -o wide
kubectl get pods --all-namespaces -o wide
```

Para eliminar el cluster hay que ejecutar:

```sh
eksctl delete cluster --name from0tocloud --region eu-west-1
```

### Cluster con EC2 estándar

Para montar el cluster hayque generar el keypair primero ejecutando el comando:

```sh
aws ec2 create-key-pair --region eu-west-1 --key-name form0tocloud-key
```

Después lanzamos la creación del cluster usando el comando:

```sh
eksctl create cluster --name from0tocloud --region eu-west-1 --with-oidc --ssh-access --ssh-public-key form0tocloud-key
```

Para comprobar que todo es correcto:

```sh
kubectl get svc
kubectl get nodes -o wide
kubectl get pods --all-namespaces -o wide
```

```sh
kubectl create namespace from0tocloud-backend
```

```sh
kubectl apply -f eureka-server/deployment.yml,api-gateway/deployment.yml,category-service/deployment.yml,item-service/deployment.yml,user-service/deployment.yml,order-service/deployment.yml
```

```sh
kubectl get all -n from0tocloud-backend 
```

```sh
kubectl logs -n kube-system deployment.apps/aws-load-balancer-controller
```

```sh
kubectl delete -f eureka-server/deployment.yml,api-gateway/deployment.yml,category-service/deployment.yml,item-service/deployment.yml,user-service/deployment.yml,order-service/deployment.yml
```

Para eliminar el cluster hay que ejecutar:

```sh
eksctl delete cluster --name from0tocloud --region eu-west-1
```

Por si se van las credenciales:

```sh
 kubectl config use-context jserrano@from0tocloud.eu-west-1.eksctl.io
 ```

 Para construir los docker y publicarlos en el AWS Registry hay que ejecutar el comando buildAndPush.sh de cada proyecto.