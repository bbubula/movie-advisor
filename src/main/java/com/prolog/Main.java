package com.prolog;

import java.io.File;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class Main {

    private static final Logger logger = LoggerFactory.getLogger(Main.class);


    public static void main(String[] args) {
        if(args.length !=1 ){
            logger.error("Invalid number of arguments. Use: <path_to_prolog_file>");
            return;
        }
        File prologFile = new File(args[0]);
        if(!prologFile.exists()){
            logger.error("Specified prolog file: " + prologFile.getAbsolutePath() + " doesn't exist");
            return;
        }
        PrologQueryExecutor prologQueryExecutor = new PrologQueryExecutor(prologFile);
        prologQueryExecutor.consultFile();
        prologQueryExecutor.executeQuery("wykonaj");
    }
}



