package agora;

import java.io.IOException;
import javax.servlet.ServletException;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.util.*;
import java.io.*;

/**
 * Servlet implementation class KillServlet
 */

public class KillServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    
    public KillServlet() {
       
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    	String pidList = request.getParameter("pid");

	Process proc = new ProcessBuilder().inheritIO().command("/home/Agora/scripts/kill.sh" , pidList).start();
   
        response.setContentType("text/plain");  
        response.setCharacterEncoding("UTF-8"); 
        response.getWriter().write(pidList); 
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException { }
}
