package com.example.demo.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;

@Entity(name = "test")
public class Test {
	
	@Column(name = "name", nullable = false, length = 50)
	private String name;
	
	@Column(name = "age", nullable = false, precision = 3)
	private int age;
	
	public Test() {
		super();
	}

	public Test(String name, int age) {
		super();
		this.name = name;
		this.age = age;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public int getAge() {
		return age;
	}

	public void setAge(int age) {
		this.age = age;
	}
	
	
	
}
