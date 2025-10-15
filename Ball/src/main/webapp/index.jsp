
<%@ page contentType="text/html; charset=UTF-8" language="java" pageEncoding="UTF-8" session="true" %>
<%@ page import="java.util.*, java.net.URLEncoder" %>
<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    // 로그인 상태면 index.jsp 대신 main.jsp로 안내 (index는 손님용)
    Object userObj = session.getAttribute("loginUser");
    String username = (String) session.getAttribute("username");
    String name = (String) session.getAttribute("name");
    boolean loggedIn = (userObj != null) || (username != null) || (name != null);
    if (loggedIn) {
        response.sendRedirect(ctx + "/main.jsp");
        return;
    }

    // 프리뷰 토글: v=matches | community
    String v = request.getParameter("v");
    if (v == null) v = "matches";
    boolean previewCommunity = "community".equalsIgnoreCase(v);

    // 커뮤니티 데이터(응용: application 스코프의 POSTS 사용)
    // 형식: Map<String, List<String>>  (카테고리 → 글제목 리스트)
    Map<String, List<String>> POSTS = (Map<String, List<String>>) application.getAttribute("POSTS");
    if (POSTS == null) {
        POSTS = new LinkedHashMap<>();
        POSTS.put("전체", new ArrayList<String>());
        POSTS.put("인기글", new ArrayList<String>());
        POSTS.put("동네질문", new ArrayList<String>());
        application.setAttribute("POSTS", POSTS);
    }

    // 커뮤니티 미리보기: 최대 4개 (전체 카테고리에서 합침)
    List<String> merged = new ArrayList<>();
    LinkedHashSet<String> uniq = new LinkedHashSet<>();
    for (Map.Entry<String, List<String>> e : POSTS.entrySet()) {
        List<String> lst = e.getValue();
        if (lst != null) uniq.addAll(lst);
    }
    merged.addAll(uniq);
    if (merged.size() > 4) merged = merged.subList(0, 4);

    // 로그인 리다이렉트 링크(상세 보려면 로그인 유도)
    String redirectCommunity = ctx + "/community.jsp";
    String loginForCommunity = ctx + "/login.jsp?redirect=" + URLEncoder.encode("community.jsp", "UTF-8");
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="utf-8" />

    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>볼피또</title>
    <link rel="icon" type="image/x-icon" href="<%=ctx%>/assets/favicon.ico" />
    <link href="<%=ctx%>/css/styles.css" rel="stylesheet" />
    <style>
        .preview-card .list-group-item { display:flex; justify-content:space-between; align-items:center; }
        .preview-card .badge { min-width:72px; text-align:center; }
        .section-muted { color:#6c757d; }
    </style>
</head>
<body>
<!-- 게스트 네비게이션 -->
<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
    <div class="container px-5">
        <a class="navbar-brand" href="<%=ctx%>/index.jsp">볼피또</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#nav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div id="nav" class="collapse navbar-collapse">
            <ul class="navbar-nav ms-auto">
                <li class="nav-item"><a class="nav-link active" href="<%=ctx%>/index.jsp">Home</a></li>
                <li class="nav-item"><a class="nav-link" href="<%=ctx%>/login.jsp">로그인</a></li>
                <li class="nav-item"><a class="nav-link" href="<%=ctx%>/register.jsp">회원가입</a></li>
            </ul>
        </div>
    </div>
</nav>

<!-- 히어로 -->
<div class="container px-4 px-lg-5">
    <div class="row gx-4 gx-lg-5 align-items-center my-5">
        <div class="col-lg-7">
            <img class="img-fluid rounded mb-4 mb-lg-0" src="<%=ctx%>/assets/img/football.png" alt="플랩풋볼 이미지" />
        </div>
        <div class="col-lg-5">
            <h1 class="fw-bold">우리의 운동 플랫폼</h1>
            <p class="text-muted">이 사이트는 경기 매칭 기능을 중심으로 제공합니다.</p>
            <a class="btn btn-primary" href="<%=ctx%>/register.jsp">지금 참여하기</a>
        </div>
    </div>

    <!-- 안내 -->
    <div class="my-5 p-3 bg-secondary text-white text-center rounded">
        심한 욕설, 불법 행위 등을 금지합니다.
    </div>

    <!-- 서비스 카드 -->
    <div class="row text-center mb-4">
        <!-- 경기 매칭: 버튼을 누르면 하단 프리뷰가 '경기'로 전환 -->
        <div class="col-md-4">
            <div class="card h-100 shadow-sm">
                <div class="card-body">
                    <h3 class="mb-2">경기 매칭</h3>
                    <p class="text-muted">경기를 뛰고 싶을 때! 원하는 지역에서 매칭을 손쉽게!</p>
                    <a href="<%=ctx%>/index.jsp?v=matches#preview"
                       class="btn btn-primary">자세히 보기</a>
                </div>
            </div>
        </div>
        <!-- 커뮤니티: 버튼을 누르면 하단 프리뷰가 '커뮤니티'로 전환 -->
        <div class="col-md-4 mt-4 mt-md-0">
            <div class="card h-100 shadow-sm">
                <div class="card-body">
                    <h3 class="mb-2">커뮤니티</h3>
                    <p class="text-muted">같은 관심사를 가진 사람들과 소통하거나 모임을 만들어요.</p>
                    <a href="<%=ctx%>/index.jsp?v=community#preview"
                       class="btn btn-outline-primary">자세히 보기</a>
                </div>
            </div>
        </div>
        <!-- 리뷰: 미리보기 대신 로그인 유도(원하면 같은 방식으로 프리뷰 추가 가능) -->
        <div class="col-md-4 mt-4 mt-md-0">
            <div class="card h-100 shadow-sm">
                <div class="card-body">
                    <h3 class="mb-2">리뷰</h3>
                    <p class="text-muted">참여했던 경기/모임에 대해 자유롭게 리뷰하고 평가해요.</p>
                    <a href="<%=ctx%>/login.jsp?redirect=<%=URLEncoder.encode("reviews.jsp","UTF-8")%>"
                       class="btn btn-outline-primary">자세히 보기</a>
                </div>
            </div>
        </div>
    </div>

    <!-- ▼ 프리뷰 영역: v 파라미터에 따라 토글 -->
    <div id="preview" class="preview-card mb-5">
        <% if (!previewCommunity) { %>
            <!-- 오늘의 경기 예약 현황 (게스트용 간략 미리보기: 데모 데이터) -->
            <h2 class="fw-bold mb-3">오늘의 경기 예약 현황</h2>
            <div class="list-group shadow-sm">
                <a class="list-group-item list-group-item-action">
                    <div>
                        <div class="h5 mb-1">12:00 경기</div>
                        <small class="section-muted">서울 풋살장 | 인원: 10 / 18</small>
                    </div>
                    <span class="badge bg-danger rounded-pill">경기 취소</span>
                </a>
                <a class="list-group-item list-group-item-action">
                    <div>
                        <div class="h5 mb-1">14:00 경기</div>
                        <small class="section-muted">서울 풋살장 | 인원: 15 / 18</small>
                    </div>
                    <span class="badge bg-success rounded-pill">예약중</span>
                </a>
                <a class="list-group-item list-group-item-action">
                    <div>
                        <div class="h5 mb-1">16:00 경기</div>
                        <small class="section-muted">서울 풋살장 | 인원: 18 / 18</small>
                    </div>
                    <span class="badge bg-success rounded-pill">예약중</span>
                </a>
                <a class="list-group-item list-group-item-action">
                    <div>
                        <div class="h5 mb-1">18:00 경기</div>
                        <small class="section-muted">서울 풋살장 | 인원: 8 / 18</small>
                    </div>
                    <span class="badge bg-danger rounded-pill">경기 취소</span>
                </a>
            </div>
        <% } else { %>
            <!-- 커뮤니티 미리보기 (최대 4개 타이틀)  -->
            <h2 class="fw-bold mb-3">커뮤니티 미리보기</h2>
            <% if (merged.isEmpty()) { %>
                <div class="alert alert-info">아직 등록된 게시글이 없습니다.</div>
                <a href="<%=loginForCommunity%>" class="btn btn-primary">첫 글 작성하기 (로그인)</a>
            <% } else { %>
                <div class="list-group shadow-sm mb-3">
                    <% for (String t : merged) {
                           String safeTitle = t == null ? "" :
                               t.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
                                .replace("\"","&quot;").replace("'","&#39;");
                    %>
                        <div class="list-group-item d-flex justify-content-between align-items-center">
                            <span class="text-truncate" style="max-width:85%"><%=safeTitle%></span>
                            <a class="btn btn-sm btn-outline-secondary"
                               href="<%=loginForCommunity%>">자세히</a>
                        </div>
                    <% } %>
                </div>
                <a href="<%=loginForCommunity%>" class="btn btn-outline-primary">커뮤니티 더 보기 (로그인)</a>
            <% } %>
        <% } %>
    </div>
    <!-- ▲ 프리뷰 영역 끝 -->

</div>

<footer class="py-5 bg-dark">
    <div class="container px-4 px-lg-5">
        <p class="m-0 text-center text-white">Copyright &copy; 볼피또 2025</p>
    </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="<%=ctx%>/js/scripts.js"></script>
</body>
</html>
