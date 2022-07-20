** primeros pasos https://github.com/Cloud-Yeti/aws-labs/tree/master/terraform-aws

** instalar Visual Studio Code
** instalar Hashicord Terraform extension para Visual Studio Code
** instalar terraform windows
** instalar git 
** instalar aws cli -> https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

** Acceso a AWS (Solo utilizar instancias Free)

** aws --version
** aws configure
** Conseguir credenciales de AWS en AMI->usuario->credenciales de acceso->crear una clave de acceso
** Obtener permisos AWS -> AMI->Usuarios->Permisos->nuevo grupo->AmazonEC2FullAccess or admin->utilizacion de la politica->asociar->seleccionar usuario

** crear instancias, clave publica, deply script y security group: https://www.youtube.com/watch?v=cCBd36n4RBU
** crear balanceador y cosas relacionadas a el: https://www.youtube.com/watch?v=cgq92b0W_AA

** clear;terraform init   
** clear;terraform plan   --> revisar si hay algun error en los archivo *.tf
** clear;terraform apply  --> yes
** si hay error, correr este comando para ver de que se trata -> aws sts decode-authorization-message --encoded-message <Encoded authorization failure message>

** Verificar que carga cada DNS publico ipv4 de las instancias creadas
** Ahora, verificar que cargue el DNS publico del balanceador y cada vez que le da F5 muestra el contenido HTML de una instnacia diferente

** terraform destroy