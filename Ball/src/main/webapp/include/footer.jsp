<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
</main>
<footer class="mt-auto py-4 bg-dark text-light">
  <div class="container text-center">

      <div class="mb-1" style="font-size: 20px; font-weight: 700;">
          ⚽ Ballpitto – Play Together, Enjoy More
      </div>

      <div class="small text-secondary">
          📍 위치 기반 경기 매칭&nbsp;&nbsp;|&nbsp;&nbsp;
          👥 파트너 찾기&nbsp;&nbsp;|&nbsp;&nbsp;
          📝 리뷰 & 커뮤니티
      </div>

  </div>
</footer>

<!-- Bootstrap JS: CSS와 같은 5.3.3 버전으로 통일 -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<!-- (선택) CDN 차단 대비 로컬 폴백 -->
<script>
  if (!window.bootstrap) {
    var s = document.createElement('script');
    s.src = '<%=request.getContextPath()%>/vendor/bootstrap/bootstrap.bundle.min.js';
    document.head.appendChild(s);
  }
</script>

<!-- 너의 커스텀 JS -->
<script src="<%=request.getContextPath()%>/js/scripts.js"></script>
</body>
</html>
