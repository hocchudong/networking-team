<?php
/*$data_string = '
{ "auth": {
    "identity": {
      "methods": ["password"],
      "password": {
        "user": {
          "name": "admin",
          "domain": {
              "name": "default"
          },
          "password": "Welcome123"
        }
      }
    }
  }
}';*/

$name=$_POST["name"];
$password=$_POST["pass"];
$domainname=$_POST["domainname"];
$data=array(
    'auth' => array(
        'identity' => array(
            'methods' => ['password'],
            'password' => array(
                  'user' => array(
                      'name' => $name,
                      'domain' => array(
                          'name' => $domainname
                      ),
                      'password' => $password
                  )
            )
        )
    )
);
//echo(json_encode($data));
echo "<br><br>";
$data_string=json_encode($data);
$urltoken='http://172.16.69.150:35357/v3/auth/tokens';
//post                                                                                                                                                                                                   
$ch = curl_init($urltoken);                                                                      
curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "POST");                                                                     
curl_setopt($ch, CURLOPT_POSTFIELDS, $data_string);                                                                  
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);                                                                      
curl_setopt($ch, CURLOPT_HTTPHEADER, array(                                                                          
    'Content-Type: application/json')                                                                       
);
curl_setopt($ch, CURLOPT_HEADER, true);                                                                                                                                                                                                                        
$result = curl_exec($ch);
$httpcode = curl_getinfo($ch, CURLINFO_HTTP_CODE); 
//echo $result;
/*echo token
preg_match('#X-Subject-Token: (.*?)\n#',$result,$token);
echo $token[1];
*/
//echo 'HTTP code: ' . $httpcode;
if ($httpcode== 201)
	echo "$name | $password | $domainname => Đăng nhập thành công";
else
	echo "$name | $password | $domainname => Đăng nhập thất bại";
echo "<br><br>";
?>
