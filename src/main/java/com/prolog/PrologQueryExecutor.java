package com.prolog;

import java.io.File;

import org.projog.api.Projog;
import org.projog.api.QueryResult;
import org.projog.api.QueryStatement;

public class PrologQueryExecutor {

	private Projog projog;

	public PrologQueryExecutor(File prologFile) {
		this.projog = new Projog();
		projog.consultFile(prologFile);
	}

	public QueryResult executeQuery(String query) {
		QueryStatement queryStatement = projog.query(query);
		QueryResult queryResult = queryStatement.getResult();
		return queryResult;
	}
}
