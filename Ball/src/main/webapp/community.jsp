<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
    String category = request.getParameter("category");
    if (category == null) category = "전체";

    Map<String, List<String>> posts = new LinkedHashMap<>();

    posts.put("전체", Arrays.asList(
            "주말마다 하는 동네 축구 모임, 관심 있으신 분?",
            "볼링 200점 돌파하려면 어떤 훈련이 좋을까요?",
            "실내 풋살장 예약 같이 하실 분 찾습니다",
            "볼링 장비(볼, 신발) 중고로 구매하려고 하는데 조언 부탁드려요",
            "볼링 200점 돌파하려면 어떤 훈련이 좋을까요?",
            "실내 풋살장 예약 같이 하실 분 찾습니다",
            "볼링 장비(볼, 신발) 중고로 구매하려고 하는데 조언 부탁드려요"
        ));
    
    posts.put("인기글", Arrays.asList(
        "이번 주 토요일 풋살 인원 모집합니다!",
        "볼링 레슨 잘하는 곳 아시는 분?",
        "축구화 새로 샀는데 추천합니다 ⚽",
        "볼링 동호회 가입 후기 공유합니다 🎳"
    ));


    posts.put("동네질문", Arrays.asList(
        "서울 강남 근처 풋살장 추천 부탁드려요",
        "야간 조명 좋은 축구장 있나요?",
        "초보도 가입할 수 있는 볼링 동호회 있을까요?",
        "볼링공 무게는 어떻게 선택하는 게 좋을까요?"
    ));

    List<String> postList = posts.getOrDefault(category, Collections.emptyList());
%>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>볼피또 - 커뮤니티</title>

  <!-- Bootstrap CSS -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

  <!-- 내 CSS -->
  <link href="<%=request.getContextPath()%>/assets/css/style.css" rel="stylesheet" />
</head>
<body class="bg-light">

  <!-- 네비게이션 -->
  <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
    <div class="container">
      <a class="navbar-brand fw-bold" href="index.jsp">볼피또</a>
      <ul class="navbar-nav ms-auto">
        <li class="nav-item"><a class="nav-link" href="index.jsp">홈</a></li>
        <li class="nav-item"><a class="nav-link active" href="community.jsp">커뮤니티</a></li>
        <li class="nav-item"><a class="nav-link" href="#">로그인</a></li>
      </ul>
    </div>
  </nav>

  <!-- 히어로 섹션 -->
  <header class="py-5 bg-white border-bottom mb-4">
    <div class="container text-center">
      <h1 class="fw-bold text-primary mb-2">커뮤니티</h1>
      <p class="text-muted">동네 소식, 질문, 자유글을 나누는 공간입니다.</p>
    </div>
  </header>

  <!-- 메인 콘텐츠 -->
  <main class="container">
    <div class="row">
      <!-- 사이드 메뉴 -->
      <aside class="col-md-3 mb-4">
        <div class="list-group shadow-sm">
          <a href="community.jsp?category=전체" class="list-group-item list-group-item-action <%= "전체".equals(category) ? "active" : "" %>">전체</a>
          <a href="community.jsp?category=인기글" class="list-group-item list-group-item-action <%= "인기글".equals(category) ? "active" : "" %>">인기글</a>
          <a href="community.jsp?category=동네질문" class="list-group-item list-group-item-action <%= "동네질문".equals(category) ? "active" : "" %>">동네질문</a>
        </div>
        <div class="d-grid mt-3">
          <a href="#" class="btn btn-primary">글쓰기</a>
        </div>
      </aside>

      <!-- 게시글 목록 -->
      <section class="col-md-9">
        <h4 class="fw-bold mb-3"><%= category %> 게시글</h4>
        <p class="text-muted small mb-4">총 <%= postList.size() %>건</p>

        <% if (postList.isEmpty()) { %>
          <div class="alert alert-info">해당 카테고리에 게시글이 없습니다.</div>
        <% } else { %>
          <div class="row row-cols-1 g-3">
            <% for (String title : postList) { %>
              <div class="col">
                <div class="card h-100 shadow-sm">
                  <div class="card-body">
                    <a href="post.jsp?title=<%= java.net.URLEncoder.encode(title, "UTF-8") %>"
                       class="stretched-link text-decoration-none">
                      <h5 class="card-title text-dark"><%= title %></h5>
                    </a>
                    <p class="card-text text-muted small">내용 미리보기…</p>
                  </div>
                </div>
              </div>
            <% } %>
          </div>
        <% } %>
      </section>
    </div>
  </main>

 <%@ include file="include/footer.jsp" %>

  <!-- Bootstrap JS -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
