<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>플랩풋볼</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />

    <!-- 파비콘 -->
    <link rel="icon" type="image/x-icon" href="<%=request.getContextPath()%>/assets/favicon.ico" />

    <!-- Bootstrap CSS (CDN) -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- 너의 커스텀 CSS (항상 Bootstrap 뒤에) -->
    <link href="<%=request.getContextPath()%>/css/styles.css" rel="stylesheet" />
</head>
<body>
    <!-- 네비게이션 -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container px-5">
            <a class="navbar-brand" href="<%=request.getContextPath()%>/index.jsp">플랩풋볼</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" 
                    data-bs-target="#navbarNav" aria-controls="navbarNav" 
                    aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>
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
