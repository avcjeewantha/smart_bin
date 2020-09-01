# Smart Bin Server Application
Node backend which calculates project measurements and feed them into front end on request of the confluence plugin _'Measurement Analysis'_. 

## Content
This document will consist of,   
 
  - [Initial Setup of the server](#initial-setup)    
  - [How to see logs](#logs)    

## Initial Setup
 > Server deployment process will be described here using "Apache daemon".            
  
  1. Install plugins and packages     
      - Node     
        ```
        sudo yum install -y gcc-c++ make\n    
        curl -sL http://rpm.nodesource.com/setup_10.x | sudo -E bash -\n    
        sudo yum install -y nodejs\n
        ```  
  
      - Apache    
        ```
        sudo yum install httpd
        ```       
      - firebase admin    
        ```
        npm install firebase-admin --save
        ```    
      - Express    
        ```
        npm install express@4.17.1 --save
        ```    
        
2. Start and enable apache daemon    
    ```
    sudo systemctl start httpd    
    sudo systemctl enable httpd
    ```    
3. Create reverse proxy using apache    
    Create reverse proxy file and edit it using `sudo nano /etc/httpd/conf.d/<filename>.conf`  (we used smartbin.conf as filename)   
     ```
        <VirtualHost *:80>    
			ProxyPreserveHost on    
			ProxyPass /smartbin http://127.0.0.1:8080   
			ProxyPassReverse /smartbin http://127.0.0.1:8080   
		</VirtualHost>    
    ``` 
    
4. Restart Apache daemon    
        ```
        sudo systemctl restart httpd
        ```    
5. Start the Node application   
    After navigating into the project folder    
    ```
    ./start
    ```    
    
    > `start` file contains the command to start the application `node app.js | rotatelogs -t logs/app.log 172800 &`
    
> If needed disable selinux using `sudo /usr/sbin/setsebool -p httpd_can_network_connect 1`
    

## Logs
Logs file will be available at `projectRootPath/logs/app.log`.
> Note: Logs will be automatically truncated after two days.