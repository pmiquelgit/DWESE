package com.daw.crudapi.controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;


@RestController  // Las respuestas se devuelven como JSON
@RequestMapping("/crudapi")  // Prefijo común de todas las URL


public class CrudApiController {
    
@GetMapping
public String index(@RequestParam String param) {
    return new String("Página principal");
}


}
