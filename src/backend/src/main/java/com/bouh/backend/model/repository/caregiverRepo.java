package com.bouh.backend.model.repository;
import com.bouh.backend.model.Dto.caregiverDto;
import com.google.cloud.firestore.Firestore;
import org.springframework.stereotype.Repository;


@Repository
public class caregiverRepo {

    //springBoot on config it will inject the globally created FireStore bean (in Config File) into this Repo instance of fireStore
    private final Firestore firestore;
    public caregiverRepo(Firestore firestore) {
        this.firestore = firestore; //set the instance so this repo use it
    }

    public caregiverDto addCaregiver(caregiverDto caregiver) throws Exception {

        firestore.collection("caregivers")
                .add(caregiver)
                .get();

        return caregiver;
    }
}
