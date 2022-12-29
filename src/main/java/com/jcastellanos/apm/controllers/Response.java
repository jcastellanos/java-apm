package com.jcastellanos.apm.controllers;

import lombok.Data;

import java.util.List;

@Data
public class Response {
    private String message;
    private String host;
    private List<String> environment;
}
