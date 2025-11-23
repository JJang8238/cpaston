package filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebFilter("/admin/*")   // ⭐ web.xml 대신 이게 필수
public class AdminFilter implements Filter {

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request  = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        HttpSession session = request.getSession(false);
        Object loginObj = (session != null) ? session.getAttribute("loginUser") : null;

        // 로그인 X → index로
        if (loginObj == null) {
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            return;
        }

        dto.User user = (dto.User) loginObj;

        // admin 아님 → index로
        if (!"admin".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            return;
        }

        chain.doFilter(req, res);
    }
}
