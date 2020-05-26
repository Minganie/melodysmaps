<?php

require_once __DIR__ . '/vendor/autoload.php';

$loader = new \Twig\Loader\FilesystemLoader(__DIR__ . '/views/');
$twig = new \Twig\Environment($loader, [
    'debug' => true
]);
$twig->addExtension(new \Twig\Extension\DebugExtension());

$dispatcher = FastRoute\simpleDispatcher(function(FastRoute\RouteCollector $r) use ($twig) {
    $r->get('/triad/', function() use ($twig) {
        echo $twig->render('intro.twig');
    });
    $r->get('/triad/combos', function() use ($twig) {
        echo $twig->render('combos.twig');
    });
    $r->get('/triad/{play}', function($vars) use ($twig) {
        $string = file_get_contents(__DIR__ . "/plays/{$vars['play']}.json");
        $play = json_decode($string, true);
        foreach($play['leftBoards'] as $i => $board) {
            $string = file_get_contents(__DIR__ . "/boards/$board.json");
            $play['leftBoards'][$i] = json_decode($string, true);
        }
        foreach($play['rightBoards'] as $i => $board) {
            $string = file_get_contents(__DIR__ . "/boards/$board.json");
            $play['rightBoards'][$i] = json_decode($string, true);
        }
        // error_log(print_r($play, true));
        echo $twig->render('play.twig', ['play' => $play]);
    });
});

$httpMethod = $_SERVER['REQUEST_METHOD'];
$uri = $_SERVER['REQUEST_URI'];
// Strip query string (?foo=bar) and decode URI
if (false !== $pos = strpos($uri, '?')) {
    $uri = substr($uri, 0, $pos);
}
$uri = rawurldecode($uri);

$routeInfo = $dispatcher->dispatch($httpMethod, $uri);
switch ($routeInfo[0]) {
    case FastRoute\Dispatcher::NOT_FOUND:
        die('Not Found');
        break;
    case FastRoute\Dispatcher::METHOD_NOT_ALLOWED:
        $allowedMethods = $routeInfo[1];
        die('Not Allowed');
        break;
    case FastRoute\Dispatcher::FOUND:
        $handler = $routeInfo[1];
        $vars = $routeInfo[2];
        print $handler($vars);
        break;
}