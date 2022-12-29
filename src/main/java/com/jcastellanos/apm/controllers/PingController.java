package com.jcastellanos.apm.controllers;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.List;

@RestController
public class PingController {
    private final MeterRegistry meterRegistry;

    public PingController(MeterRegistry registry) {
        this.meterRegistry = registry;
    }

    @GetMapping("/java-apm/counter")
    public Response ping(@RequestParam(name = "msg", defaultValue = "", required = false) String msg) throws UnknownHostException {
        properties();
        List<String> envs = envs();
        if(msg == null || msg.isEmpty() || ! "exception".equals(msg) ) {
            Response res = new Response();
            res.setMessage("Counter incremented");
            res.setHost(InetAddress.getLocalHost().getHostName());
            res.setEnvironment(envs);
            Counter counter = meterRegistry.counter("app.java-apm.counter", "status","ok");
            counter.increment();
            return res;
        } else {
                Counter counter = meterRegistry.counter("app.java-apm.counter", "status", "error");
                counter.increment();
                throw new RuntimeException("Forced error in msg");
        }
    }

    private void properties() {
        System.out.println("--- Properties:");
        System.getProperties().list(System.out);
    }

    private List<String> envs() {
        List<String> envs = new ArrayList<>();
        System.out.println("--- Envs:");
        System.getenv().forEach((key, val) -> {
            envs.add(key + " : " + val);
            System.out.println(key + " : " + val);
        });
        return envs;
    }
}
