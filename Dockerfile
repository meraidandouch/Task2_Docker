# escape =`
#1. Get the rocker/shiny-verse:4.0.3 image from Dockerhub to use as base image
#1.1 Laptops with a Apple M1 Pro chip have ARM architecture and currently rocker/shiny doesn't 
#1.2 support ARM architecture so I will use base r and install shiny as a dependency instead  
FROM r-base:latest
    
#2. Set up a volume directory called /srv/shiny-server inside the Docker image
#2.1 The volume instruction creates a mount point with where all shiny stuff will be allocated and stored 
VOLUME /srv/shiny-server

#3. Set /srv/shiny-server as a working directory inside the Docker image
#3.1 Here we are setting the working directory to the mount delcared above to make reading and writing simpler
WORKDIR /srv/shiny-server

#4. Copy app.R in your ShinyApps folder to /srv/shiny-server inside the Docker image
COPY ShinyApps/app.R /srv/shiny-server

#5. Copy run_app.R in your ShinyApps folder to /srv/shiny-server inside the Docker image
COPY ShinyApps/run_app.R /srv/shiny-server

#6. Update and install system libraries (e.g., libudunits2-dev, libv8-dev, libsodium-dev) for general use
#6.1 Because we are starting from a minimal base image (like a brand new computer), our app.R and RShiny app utilizes certain features such as units, HTML, javascript
#6.2 we need to ensure that common debian libraries such libv8-dev and libsodium-dev are installed on the machine to handle R features
#6.3 these packages may already be installed on the users machine, especially if they have R installed,
#6.4 but its best to assume they don't and require they update it and install it 
#6.5 Why do we need said packages? libudunits2-dev - unit conversion, libv8-dev - javascript, libsodium-dev - encryption and hashing 
RUN apt-get update && apt-get -y install -y `
	libudunits2-dev `
	libv8-dev `
	libsodium-dev `
	&& rm -rf /var/lib/apt/lists/*


#7. Install the required R packages to run the shiny app
RUN R -e "install.packages(c('shiny'), repos='http://cran.rstudio.com/')"

#8. Expose the app to port 3838 inside the Docker image
#8.1 Container port is configuring Rshiny server to use port 3838
#8.2 Port 8080 is commonly used port for webapplications
#8.3 To get Container port 3838 listening to any 'knocks' from port 8080 you can just expose 3838
#8.4 and map the porting to 8080 by using -p flag in docker and typing 8080:3838
EXPOSE 3838

#9. Copy shiny-server.sh file that runs the shiny application to /usr/bin/shiny-server.sh inside the Docker image
COPY shiny-server.sh /usr/bin/shiny-server.sh

#10. Allow read, write, and execute permissions to /srv/shiny-server directory inside the Docker image
RUN chmod -R 777 /srv/shiny-server

#11. Allow execute permission to /usr/bin/shiny-server.sh file inside the Docker image. 
RUN chmod +x /usr/bin/shiny-server.sh

#12. Execute /usr/bin/shiny-server.sh file to launch the Shiny app inside the Docker image
CMD Rscript ShinyApps/run_app.R
