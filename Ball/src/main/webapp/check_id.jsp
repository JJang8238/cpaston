<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="dao.UserDAO" %>

<%
    request.setCharacterEncoding("UTF-8");
    String username = request.getParameter("username");
    boolean isAvailable = false;

    if (username != null && !username.trim().isEmpty()) {
        UserDAO dao = new UserDAO();
        isAvailable = dao.isAvailable(username);
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>아이디 중복 확인</title>
    <style>
        body {
            font-family: '맑은 고딕', sans-serif;
            padding: 30px;
            font-size: 16px;
        }
        .message {
            margin-bottom: 20px;
        }
        .available {
            color: green;
            font-weight: bold;
        }
        .unavailable {
            color: red;
            font-weight: bold;
        }
        button {
            padding: 5px 15px;
        }
    </style>
</head>
<body>
    <div class="message">
        <%
            if (username == null || username.trim().isEmpty()) {
        %>
            <span class="unavailable">아이디를 입력해주세요.</span>
        <%
            } else if (isAvailable) {
        %>
            <span class="available"><%= username %></span>는 사용 가능한 아이디입니다.
        <%
            } else {
        %>
            <span class="unavailable"><%= username %></span>는 이미 사용 중인 아이디입니다.
        <%
            }
        %>
    </div>
    <button onclick="window.close()">닫기</button>
</body>
</html>
