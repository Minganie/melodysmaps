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
    // error_log(print_r($_GET, true));
    // SEARCH
    if(isset($_GET['search']) && !empty($_GET['search']))
    {
        $search = $_GET['search'];
        // error_log("Searching for '$search'");
        $stmt = $conn->prepare("SELECT get_search(?)");
        $worked = $stmt->execute(array($search));
        $result = format_response($worked, $stmt);
    }
    
    // CATEGORIES
    if(isset($_GET['category']) && !empty($_GET['category']))
    {
        $category = $_GET['category'];
        if($category === 'all')
        {
            $stmt = $conn->prepare("SELECT get_categories()");
            $worked = $stmt->execute();
        }
        else
        {
            $stmt = $conn->prepare("SELECT get_category(?)");
            $worked = $stmt->execute(array($category));
        }
        $result = format_response($worked, $stmt);
    }
    
    // REGION
    if(isset($_GET['region']) && !empty($_GET['region']))
    {
        $region = $_GET['region'];
        if($region === 'all')
        {
            $stmt = $conn->prepare("SELECT get_regions()");
            $worked = $stmt->execute();
        }
        else
        {
            $stmt = $conn->prepare("SELECT get_region(?)");
            $worked = $stmt->execute(array($region));
        }
        $result = format_response($worked, $stmt);
    }
    
    // ZONE
    if(isset($_GET['zone']) && !empty($_GET['zone']))
    {
        $zone = $_GET['zone'];
        if($zone === 'all')
        {
            $stmt = $conn->prepare("SELECT get_zones()");
            $worked = $stmt->execute();
        }
        else
        {
            $stmt = $conn->prepare("SELECT get_zone(?)");
            $worked = $stmt->execute(array($zone));
        }
        $result = format_response($worked, $stmt);
    }
    
    // AREA
    if(isset($_GET['area']) && !empty($_GET['area']))
    {
        $area = $_GET['area'];
        if($area === 'all')
        {
            $stmt = $conn->prepare("SELECT get_areas()");
            $worked = $stmt->execute();
        }
        else
        {
            $stmt = $conn->prepare("SELECT get_area(?)");
            $worked = $stmt->execute(array($area));
        }
        $result = format_response($worked, $stmt);
    }
    
    // AETHERYTES
    if(isset($_GET['aetheryte']) && !empty($_GET['aetheryte']))
    {
        $aetheryte = $_GET['aetheryte'];
        if($aetheryte === 'all')
        {
            $stmt = $conn->prepare("SELECT get_aetherytes()");
            $worked = $stmt->execute();
        }
        else
        {
            $stmt = $conn->prepare("SELECT get_aetheryte(?)");
            $worked = $stmt->execute(array($aetheryte));
        }
        $result = format_response($worked, $stmt);
    }
    
    // CHOCOBOS
    if(isset($_GET['chocobo']) && !empty($_GET['chocobo']))
    {
        $chocobo = $_GET['chocobo'];
        if($chocobo === 'all')
        {
            $stmt = $conn->prepare("SELECT get_chocobos()");
            $worked = $stmt->execute();
        }
        else
        {
            $stmt = $conn->prepare("SELECT get_chocobo(?)");
            $worked = $stmt->execute(array($chocobo));
        }
        $result = format_response($worked, $stmt);
    }
    
    // MOOGLES
    if(isset($_GET['moogle']) && !empty($_GET['moogle']))
    {
        $moogle = $_GET['moogle'];
        if($moogle === 'all')
        {
            $stmt = $conn->prepare("SELECT get_moogles()");
            $worked = $stmt->execute();
        }
        else
        {
            $stmt = $conn->prepare("SELECT get_moogle(?)");
            $worked = $stmt->execute(array($moogle));
        }
        $result = format_response($worked, $stmt);
    }
    
    // DUTIES
    if(isset($_GET['duty']) && !empty($_GET['duty']))
    {
        $duty = $_GET['duty'];
        if($duty === 'all')
        {
            $stmt = $conn->prepare("SELECT get_duties()");
            $worked = $stmt->execute();
        }
        else if(isset($_GET['mode']) && !empty($_GET['mode']))
        {
            $stmt = $conn->prepare("SELECT get_duty_each(?)");
            $worked = $stmt->execute(array($duty));
        } else {
            $stmt = $conn->prepare("SELECT get_duty(?)");
            $worked = $stmt->execute(array($duty));
        }
        $result = format_response($worked, $stmt);
    }
    
    // ITEM
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
    
    // GATHERING
    if(isset($_GET['node']) && !empty($_GET['node']))
    {
        $node = $_GET['node'];
        $stmt = $conn->prepare("SELECT get_node(?)");
        $worked = $stmt->execute(array($node));
        $result = format_response($worked, $stmt);
    }
    
    // HUNTING GROUND
    // if(isset($_GET['lootable_mob']) && !empty($_GET['lootable_mob']))
    // {
        // $lootable_mob = $_GET['lootable_mob'];
        // $stmt = $conn->prepare("SELECT get_lootable_mob(?)");
        // $worked = $stmt->execute(array($lootable_mob));
        // $result = format_response($worked, $stmt);
    // }
    
    // MOB
    if(isset($_GET['monster']) && !empty($_GET['monster']))
    {
        $mob = $_GET['monster'];
        $stmt = $conn->prepare("SELECT get_mob(?)");
        $worked = $stmt->execute(array($mob));
        $result = format_response($worked, $stmt);
    }
    
    // MERCHANT
    if(isset($_GET['merchant']) && !empty($_GET['merchant']))
    {
        $merchant = $_GET['merchant'];
        // if($merchant === 'all')
        // {
            // $stmt = $this->conn->prepare("SELECT get_merchants()");
            // $worked = $stmt->execute();
            
        // }
        // else
        // {
            $stmt = $conn->prepare("SELECT get_merchant(?)");
            $worked = $stmt->execute(array($merchant));
        // }
        $result = format_response($worked, $stmt);
    }
    
    // VISTA
    if(isset($_GET['vista']) && !empty($_GET['vista']))
    {
        $vista = $_GET['vista'];
        // if($vista === 'all')
        // {
            // $stmt = $this->conn->prepare("SELECT get_vistas()");
            // $worked = $stmt->execute();
        // }
        // else
        // {
            $stmt = $conn->prepare("SELECT get_vista(?)");
            $worked = $stmt->execute(array($vista));
        // }
        $result = format_response($worked, $stmt);
    }
    
    // NPC
    if(isset($_GET['npc']) && !empty($_GET['npc']))
    {
        // GET param can be a string or an int, and that's two
        // different functions in DB (because Leve deliveries <>
        // general NPC search)
        $npc = $_GET['npc'];
        if(is_numeric($npc)) {
            $f = "get_npc_from_id";
        } else {
            $f = "get_npc";
        }
        $sql = "SELECT $f(?)";
        $stmt = $conn->prepare($sql);
        $worked = $stmt->execute(array($npc));
        $result = format_response($worked, $stmt);
    }
    
    // Lodestone NPC
    if(isset($_GET['lnpc']) && !empty($_GET['lnpc']))
    {
        $npc = $_GET['lnpc'];
        $sql = "SELECT get_mobile(?)";
        $stmt = $conn->prepare($sql);
        $worked = $stmt->execute(array($npc));
        $result = format_response($worked, $stmt);
    }
    
    // LEVEMETE
    if(isset($_GET['levemete']) && !empty($_GET['levemete']))
    {
        $levemete = $_GET['levemete'];
        $stmt = $conn->prepare("SELECT get_levemete(?)");
        $worked = $stmt->execute(array($levemete));
        $result = format_response($worked, $stmt);
    }
    
    // LEVE
    if(isset($_GET['leve']) && !empty($_GET['leve']))
    {
        $leve = $_GET['leve'];
        $stmt = $conn->prepare("SELECT get_leve(?)");
        $worked = $stmt->execute(array($leve));
        $result = format_response($worked, $stmt);
    }
    
    // RECIPE
    if(isset($_GET['recipe']) && !empty($_GET['recipe']))
    {
        $recipe = $_GET['recipe'];
        $stmt = $conn->prepare("SELECT get_recipe(?)");
        $worked = $stmt->execute(array($recipe));
        $result = format_response($worked, $stmt);
    }
    
    // QUEST
    if(isset($_GET['quest']) && !empty($_GET['quest']))
    {
        $quest = $_GET['quest'];
        $stmt = $conn->prepare("SELECT get_quest(?)");
        $worked = $stmt->execute(array($quest));
        $result = format_response($worked, $stmt);
    }
	
	// HUNTING LOGS
	if(!empty($_GET['hunting_logs']))
	{
		$stmt = $conn->prepare("SELECT get_hunting_logs()");
        $worked = $stmt->execute();
        $result = format_response($worked, $stmt);
	}
}

echo $result;

?>