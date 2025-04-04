In general, this was my first try ever to set up minikube and anything kubernetes-related. The process was not so hard, but there still were some challenges for me. 
I'll describe steps I've taken to get it done below.
1. Set up a VPS on Ubuntu 22.04. Nothing to add here, as the process is pretty automated.
2. Made sure all the software on the OS is up to date.
3. Installed Docker (at this point I was not sure if I needed to install it separately or the Minikube has it's own service included, so I just proceeded with installation to make sure)
4. Created separate user to be used with Docker and Minikube and added it to the respective groups.
5. Installed Minikube
6. Created default basic .yaml files to deploy Nginx. 
7. Messed around for some time with setting up Ingress but abandoned it as I was not able to make it accessible through the internet.
8. Decided to go with LoadBalancer, cleaned up installation, added .yaml for LoadBalancer.
9. Created tunnel and binded it to the IP of the VPS (which was important, as I've spent some time figuring out why me networking configs were not working and the setup was not accessible via web without ip bindning) with `minikube tunnel --bind-address='203.161.63.211'`.
10. Accessed the http://thehereandnow.us/ domain in browser and got extremely satisfied :D
