package com.example.demo.entity;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class TestController {
	
	@Autowired
	TestRepository repository;
	
	@PostMapping("/insert")
	public void saveUser(@RequestParam(name = "name") String name, 
			@RequestParam(name = "age") int age) {
		Test test = new Test(name, age);
		repository.save(test);
	}
	
}
