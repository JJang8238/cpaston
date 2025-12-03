<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.net.*, java.io.*" %>
<%
    request.setCharacterEncoding("UTF-8");

    String query = request.getParameter("query");
    if (query == null || query.trim().isEmpty()) query = "풋살장";

    // ▼▼ 여기에 developers.naver.com 에서 발급받은 Client ID/Secret을 넣으세요 ▼▼
    final String CLIENT_ID     = "488clthHKbpF0Cjn64m_";
    final String CLIENT_SECRET = "PLyxL9k7i_";
    // ▲▲--------------------------------------------------------------------▲▲

    String apiURL = "https://openapi.naver.com/v1/search/local.json?query="
            + URLEncoder.encode(query, "UTF-8")
            + "&display=20&start=1&sort=random";

    HttpURLConnection con = null;
    BufferedReader br = null;

    try {
        URL url = new URL(apiURL);
        con = (HttpURLConnection) url.openConnection();
        con.setRequestMethod("GET");
        con.setRequestProperty("X-Naver-Client-Id", CLIENT_ID);
        con.setRequestProperty("X-Naver-Client-Secret", CLIENT_SECRET);

        int responseCode = con.getResponseCode();
        InputStream is = (responseCode == 200) ? con.getInputStream() : con.getErrorStream();
        br = new BufferedReader(new InputStreamReader(is, "UTF-8"));

        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = br.readLine()) != null) sb.append(line);

        out.print(sb.toString());   // 그대로 프록시
    } catch (Exception e) {
        e.printStackTrace();
        out.print("{\"items\":[],\"errorMessage\":\"" + e.getMessage().replace("\"","\\\"") + "\"}");
    } finally {
        if (br != null) try { br.close(); } catch (Exception ignore) {}
        if (con != null) con.disconnect();
    }
%>
