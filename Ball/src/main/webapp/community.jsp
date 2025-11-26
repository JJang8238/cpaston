<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="dao.PostDAO, dto.Post" %>
<%@ page import="dto.User" %>

<%
  request.setCharacterEncoding("UTF-8");
  String ctx = request.getContextPath();

  User loginUser = (User) session.getAttribute("loginUser");

  String category = request.getParameter("category");
  if (category == null) category = "전체";
  List<String> allowed = Arrays.asList("전체","인기글","동네질문");
  if (!allowed.contains(category)) category = "전체";

  List<Post> posts;
  try (PostDAO dao = new PostDAO()) {
      posts = dao.list(category);
  }

  String safeCategory = category
      .replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
      .replace("\"","&quot;").replace("'","&#39;");
%>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>볼피또 - 커뮤니티</title>

  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

  <style>
    body { background:#f8f9fa; }
  </style>

</head>

<body class="d-flex flex-column min-vh-100">


  <jsp:include page="/nav.jsp" />


  <header class="py-5 bg-white border-bottom mb-4">
    <div class="container text-center">
      <h1 class="fw-bold text-primary mb-2">커뮤니티</h1>
      <p class="text-muted mb-0">동네 소식, 질문, 자유글을 나누는 공간입니다.</p>
    </div>
  </header>



  <main class="container flex-grow-1 pb-5">
    <div class="row">

      <!-- 좌측 -->
      <aside class="col-md-3 mb-5">
        <div class="list-group shadow-sm">
          <a href="<%=ctx%>/community.jsp?category=전체"
             class="list-group-item list-group-item-action <%= "전체".equals(category) ? "active" : "" %>">전체</a>
          <a href="<%=ctx%>/community.jsp?category=인기글"
             class="list-group-item list-group-item-action <%= "인기글".equals(category) ? "active" : "" %>">인기글</a>
          <a href="<%=ctx%>/community.jsp?category=동네질문"
             class="list-group-item list-group-item-action <%= "동네질문".equals(category) ? "active" : "" %>">동네질문</a>
        </div>

        <div class="d-grid mt-3">
          <a href="<%=ctx%>/write.jsp?category=<%=category%>" class="btn btn-primary">글쓰기</a>

        </div>
      </aside>

      <!-- 게시글 목록 -->
      <section class="col-md-9 mb-5">
        <div class="d-flex align-items-center gap-2 mb-2">
          <h4 class="fw-bold mb-0"><%= safeCategory %> 게시글</h4>
          <span class="badge bg-secondary">총 <%= posts.size() %>건</span>
        </div>

        <% if (posts.isEmpty()) { %>
          <div class="alert alert-info">해당 카테고리에 게시글이 없습니다.</div>
        <% } else { %>

        <div class="row row-cols-1 g-3">

        <% for (Post p : posts) {

            String title = (p.getTitle()==null?"":p.getTitle())
                .replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
                .replace("\"","&quot;").replace("'","&#39;");

            String dateStr = (p.getCreatedAt()==null) ? "" :
                   new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(p.getCreatedAt());

            boolean isBest = (p.getLikes() >= 5 && p.getDislikes() <= 3);
        %>

          <div class="col">
            <div class="card h-100 shadow-sm">
              <div class="card-body">

                <!-- 제목 + BEST -->
                <h5 class="card-title text-dark mb-1 d-flex align-items-center gap-2">
                  <a href="<%=ctx%>/post.jsp?id=<%=p.getId()%>" class="text-dark text-decoration-none">
                    <%= title %>
                  </a>

                  <span class="badge rounded-pill bg-success best-badge"
                        style="<%= isBest ? "" : "display:none;" %>">
                    BEST
                  </span>
                </h5>

                <!-- 작성자 -->
                <p class="text-muted small mb-2">
                  <%= p.getAuthor() %> · <%= dateStr %>
                </p>

                <!-- 좋아요/싫어요 + 신고버튼 오른쪽 정렬 -->
                <div class="d-flex align-items-center justify-content-between">

                  <!-- 왼쪽: 좋아요/싫어요 -->
                  <div class="d-flex align-items-center gap-2">
                    <button type="button"
                            class="btn btn-sm btn-outline-primary btn-like"
                            data-id="<%=p.getId()%>">
                      👍 <span class="like-count"><%= p.getLikes() %></span>
                    </button>

                    <button type="button"
                            class="btn btn-sm btn-outline-secondary btn-dislike"
                            data-id="<%=p.getId()%>">
                      👎 <span class="dislike-count"><%= p.getDislikes() %></span>
                    </button>
                  </div>

                  <!-- 오른쪽: 신고 버튼/배지 -->
                  <div class="right-area">
                    <% if (p.getDislikes() >= 7 && p.getReports() < 7) { %>
                      <button type="button"
                              class="btn btn-sm btn-outline-danger btn-report"
                              data-id="<%=p.getId()%>">
                        🚨 신고
                      </button>
                    <% } %>

                    <% if (p.getReports() >= 7) { %>
                      <span class="badge bg-danger report-badge">🚨 신고 누적됨</span>
                    <% } %>
                  </div>


                </div>

              </div>
            </div>
          </div>

        <% } %>

        </div>
        <% } %>

      </section>
    </div>
  </main>


  <footer class="mt-auto py-4 bg-dark text-light">
    <div class="container text-center">
      <small>Copyright © 볼피또 <%= java.time.Year.now() %></small>
    </div>
  </footer>

<script>
document.addEventListener("DOMContentLoaded", () => {

  const loginUser = "<%= (loginUser != null ? loginUser.getUsername() : "") %>";

  // 공통: 신고 UI 업데이트
  function updateReportUI(container, data) {
    const rightArea   = container.querySelector(".right-area");
    let reportBtn     = rightArea.querySelector(".btn-report");
    let reportBadge   = rightArea.querySelector(".report-badge");

    // 이미 신고 누적 상태라면 배지만 보여주기
    if (data.reports >= 1) {
      if (reportBtn) reportBtn.remove();
      if (!reportBadge) {
        reportBadge = document.createElement("span");
        reportBadge.className = "badge bg-danger report-badge";
        reportBadge.textContent = "🚨 신고 누적됨";
        rightArea.appendChild(reportBadge);
      } else {
        reportBadge.style.display = "inline-block";
      }
      return;
    }

    // 아직 신고 누적은 아니지만, 싫어요 7 이상이면 신고 버튼 노출
    if (data.dislikes >= 7) {
      if (!reportBtn) {
        reportBtn = document.createElement("button");
        reportBtn.className = "btn btn-sm btn-outline-danger btn-report";
        reportBtn.dataset.id = data.id;
        reportBtn.textContent = "🚨 신고";
        rightArea.appendChild(reportBtn);

        reportBtn.addEventListener("click", () => {
          sendAction(data.id, "report", { container });
        });
      } else {
        reportBtn.style.display = "inline-block";
      }
    } else {
      // 싫어요 7 미만이면 신고 버튼 숨김
      if (reportBtn) reportBtn.style.display = "none";
    }
  }

  // AJAX 공통 함수
  function sendAction(postId, action, elems) {

    if (!loginUser) {
      alert("로그인 후 이용 가능합니다.");
      return;
    }

    fetch("<%=ctx%>/post-like", {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8" },
      body: new URLSearchParams({ id: postId, action: action })
    })
    .then(res => res.json())
    .then(data => {
      console.log("post-like 응답:", data);

      // ok 필드가 있고 false면 실패로 처리
      if (data.ok === false) {
        if (action === "report") {
          alert("이미 신고 완료되었습니다.");
        }
        return;
      }

      const container = elems.container;
      const likeSpan = container.querySelector(".like-count");
      const dislikeSpan = container.querySelector(".dislike-count");
      const bestBadge = container.querySelector(".best-badge");

      // 숫자 업데이트
      if (likeSpan && typeof data.likes === "number") {
        likeSpan.textContent = data.likes;
      }
      if (dislikeSpan && typeof data.dislikes === "number") {
        dislikeSpan.textContent = data.dislikes;
      }

      // BEST 토글
      if (bestBadge && typeof data.likes === "number" && typeof data.dislikes === "number") {
        const isBest = (data.likes >= 5 && data.dislikes <= 3);
        bestBadge.style.display = isBest ? "inline-block" : "none";
      }

      // 신고일 경우 알림 + 신고 UI 갱신
      if (action === "report") {
        alert("신고가 접수되었습니다.");
      }

      // 신고/싫어요 관련 UI 갱신
      // (data.id, data.dislikes, data.reports 가 넘어온다고 가정)
      if (!data.id) data.id = postId;
      updateReportUI(container, data);
    })
    .catch(err => {
      console.error("post-like 에러:", err);
      if (action === "report") {
        alert("신고 처리 중 오류가 발생했습니다.");
      }
    });
  }

  // 좋아요
  document.querySelectorAll(".btn-like").forEach(btn => {
    btn.addEventListener("click", () => {
      const card = btn.closest(".card-body");
      const postId = btn.dataset.id;
      sendAction(postId, "like", { container: card });
    });
  });

  // 싫어요
  document.querySelectorAll(".btn-dislike").forEach(btn => {
    btn.addEventListener("click", () => {
      const card = btn.closest(".card-body");
      const postId = btn.dataset.id;
      sendAction(postId, "dislike", { container: card });
    });
  });

  // 초기 신고 버튼 (이미 7 이상인 경우)
  document.querySelectorAll(".btn-report").forEach(btn => {
    btn.addEventListener("click", () => {
      const card = btn.closest(".card-body");
      const postId = btn.dataset.id;
      sendAction(postId, "report", { container: card });
    });
  });

});
</script>

</body>
</html>
