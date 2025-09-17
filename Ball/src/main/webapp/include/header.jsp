<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>플랩풋볼</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link rel="icon" type="image/x-icon" href="<%=request.getContextPath()%>/assets/favicon.ico" />
    <link href="<%=request.getContextPath()%>/css/styles.css" rel="stylesheet" />
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container px-5">
            <a class="navbar-brand" href="<%=request.getContextPath()%>/index.jsp">플랩풋볼</a>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav ms-auto mb-2 mb-lg-0">
                    <li class="nav-item"><a class="nav-link active" href="<%=request.getContextPath()%>/index.jsp">Home</a></li>
                    <li class="nav-item"><a class="nav-link" href="<%=request.getContextPath()%>/login.jsp">로그인</a></li>
                    <li class="nav-item"><a class="nav-link" href="<%=request.getContextPath()%>/register.jsp">회원가입</a></li>
                </ul>
            </div>
        </div>
    </nav>
    <main class="container px-4 py-5">
