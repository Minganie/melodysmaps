<?php

require_once('private.php');

function conn()
{
    $conn = null;
    $user = Privates::USER;
    $pw = Privates::PW;
    
    try
    {
        if(true){
            $host = "localhost";
        }else{
            $host = '103.11.65.78';
        }
        $conn = new PDO('pgsql:host='.$host.';port=5432;dbname=ffxiv;user='.$user.';password='.$pw);
    }
    catch(Exception $e)
    {
        error_log("Connection error: ".$e->getMessage());
    }
    return $conn;
}
function format_response($worked, $stmt)
{
    // error_log("format_response");
    $rep = json_encode(array());
    if($worked && $stmt->rowCount()==1)
    {
        // error_log('OK');
        $row = $stmt->fetch();
        $rep = $row[0];
    }
    else
    {
        // error_log('Not OK');
        $ct = print_r($stmt->errorInfo(), true);
        error_log($ct);
    }
    return $rep;
}

$result = json_encode(array());
if($conn = conn()) 
{
    if(isset($_GET['search']) && !empty($_GET['search']))
    {
        $search = $_GET['search'];
        // error_log("Searching for '$search'");
        $stmt = $conn->prepare("SELECT get_search(?)");
        $worked = $stmt->execute(array($search));
        $result = format_response($worked, $stmt);
    }
    
    if(isset($_GET['item']) && !empty($_GET['item']))
    {
        $item = $_GET['item'];
        if(isset($_GET['sources']) && !empty($_GET['sources']) && ($_GET['sources'] === 'true'))
        {
            $stmt = $conn->prepare("SELECT get_item_sources(?)");
            $worked = $stmt->execute(array($item));
        }
        else
        {
            $stmt = $conn->prepare("SELECT get_item(?)");
            $worked = $stmt->execute(array($item));
        }
        $result = format_response($worked, $stmt);
    }
}

echo $result;

?>