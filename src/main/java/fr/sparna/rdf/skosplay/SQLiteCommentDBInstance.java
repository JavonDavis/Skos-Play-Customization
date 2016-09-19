package fr.sparna.rdf.skosplay;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import java.sql.*;
import java.util.HashMap;
import java.util.ArrayList;

public class SQLiteCommentDBInstance {

	private static SQLiteCommentDBInstance instance;
	private Connection connection;
	private Logger log = LoggerFactory.getLogger(this.getClass().getName());

	private final String DB_URL = "jdbc:mysql://localhost/SkosPlay";

	private final String USER = "skos-play";
	private final String PASS = "MSBM-20166102";

	private SQLiteCommentDBInstance() {
		try {
			Class.forName("com.mysql.jdbc.Driver");
			connection = DriverManager.getConnection(DB_URL, USER, PASS);
		} catch (Exception e) {
			log.error( e.getClass().getName() + ": " + e.getMessage());
		}
	}

	public static SQLiteCommentDBInstance getInstance() {
		if (instance == null) {
			instance = new SQLiteCommentDBInstance();
		}

		return instance;
	}


	public ArrayList<HashMap> getComments() {
		Statement statement; 
		ArrayList<HashMap> comments = new ArrayList<HashMap>();
		try {
			connection.setAutoCommit(false);

			statement = connection.createStatement();
			ResultSet rs = statement.executeQuery( "SELECT * FROM comments ORDER BY id desc LIMIT 15;" );

			while ( rs.next() ) {
				int id = rs.getInt("id");
				String username = rs.getString("username");
				String content = rs.getString("content");
				String concept = "";
				if (concept != null){					
					concept = rs.getString("concept");
				}

				HashMap comment = new HashMap();

				comment.put("id", id);
				comment.put("username", username);
				comment.put("content", content);
				if (concept != null)
					comment.put("concept", concept);

				comments.add(comment);
			}
		} catch (Exception e) {
			log.error( e.getClass().getName() + ": " + e.getMessage());
		}
		return comments;
	}

	public boolean addComment(String username, String content, String concept) {
		String insertSQL = "INSERT INTO comments (username, content, concept) values (?,?,?)";

		try {
			PreparedStatement preparedStatement = connection.prepareStatement(insertSQL);
			preparedStatement.setString(1, username);
			preparedStatement.setString(2, content);
			if (concept == null) {
				concept = "";
			}
			preparedStatement.setString(3, concept);
			preparedStatement.executeUpdate();
			connection.commit();
			return true;
		} catch (SQLException e) {
			log.error( e.getClass().getName() + ": " + e.getMessage());
		}

		return false;
	}

}