package com.bouh.backend.controller;

import com.bouh.backend.model.Dto.caregiverDto;
import com.bouh.backend.model.Dto.childDto;
import com.bouh.backend.service.serviceImp.testImpl;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/test")
public class test {

    private final testImpl testCaregiverService;
    public test(testImpl testCaregiverService) {
        this.testCaregiverService = testCaregiverService;
    }

    @GetMapping("/caregiver") //just so we can see it in the browser
    public caregiverDto testCreateCaregiver() throws Exception {


        //Dummy
        childDto child1 = new childDto();
        child1.setChildId("child-1");
        child1.setName("Sara");
        child1.setGender("Female");
        //Dummy
        childDto child2 = new childDto();
        child2.setChildId("child-2");
        child2.setName("Omar");
        child2.setGender("Male");
        //Dummy
        caregiverDto caregiver = new caregiverDto();
        caregiver.setName("Test Caregiver");
        caregiver.setEmail("test@care.com");
        caregiver.setFcmToken("dummy-fcm-token");
        caregiver.setChildren(List.of(child1, child2));

        //contact the Service to then Return the object to the client Calling this endpoint
        return testCaregiverService.createCaregiver(caregiver);
    }
}