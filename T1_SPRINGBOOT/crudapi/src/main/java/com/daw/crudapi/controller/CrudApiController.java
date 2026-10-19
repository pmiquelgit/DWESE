package com.daw.crudapi.controller;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.daw.crudapi.model.Cliente;
import com.daw.crudapi.repository.ClienteRepository;


@RestController  // Las respuestas se devuelven como JSON
@RequestMapping("/crudapi")  // Prefijo común de todas las URL


public class CrudApiController {
    
    @Autowired 
    ClienteRepository repoCli;

@GetMapping
public String index() {

    Cliente cliente = new Cliente(1L, "Pedro", "Jimenez", "pepe@gmail.com", "564356464", null, null)

    // Guardamos el cliente en BBDD con save
    // Esto hace un insert en BBDD
    // Devuelve una entity que representa al registro guardado en BBDD

    Cliente clienteGuardado = repoCli.save(cliente);

    // Si modificamos los datos del cliente y hacemos save otra vez
    // En este caso hace un update ya que la entity esta mapeada en BBDD
    
    clienteGuardado.setApellidos("Gonzalez Savedra");

    repoCli.save(clienteGuardado);

    return new String("Página principal");
}


}
