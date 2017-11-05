package com.prolog;

import java.io.File;

import org.projog.api.QueryResult;

import org.projog.core.term.Atom;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class Main {

	private static final Logger logger = LoggerFactory.getLogger(Main.class);


	public static void main(String[] args) {
		if(args.length != 1){
			logger.error("Invalid number of arguments. Use: <path_to_prolog_file>");
		}
		String prologFilePath = args[0];
		PrologQueryExecutor prologQueryExecutor = new PrologQueryExecutor(new File(prologFilePath));
		QueryResult queryResult = prologQueryExecutor.executeQuery("test(X,Y).");
		while (queryResult.next()) {
			System.out.println("X = " + queryResult.getTerm("X") + " Y = " + queryResult.getTerm("Y"));
		}

		QueryResult queryResult1 = prologQueryExecutor.executeQuery("test(X,Y).");
		queryResult1.setTerm("X", new Atom("d"));
		while (queryResult1.next()) {
			System.out.println("Y = " + queryResult1.getTerm("Y"));
		}
	}
}
