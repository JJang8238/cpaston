package filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * 로그인하지 않은 사용자의 sports.jsp / community.jsp 접근을 차단.
 * 세션 키: loginUser / userId / username 중 하나라도 있으면 로그인으로 간주.
 */
@WebFilter(urlPatterns = { "/sports.jsp", "/community.jsp" })
public class AuthFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req  = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        HttpSession session = req.getSession(false);
        boolean loggedIn = false;
        if (session != null) {
            Object loginUser = session.getAttribute("loginUser");
            Object userId    = session.getAttribute("userId");
            Object username  = session.getAttribute("username");
            loggedIn = (loginUser != null) || (userId != null) || (username != null);
        }

        if (!loggedIn) {
            resp.sendRedirect(req.getContextPath() + "/index.jsp");
            return;
        }
        chain.doFilter(request, response);
    }
}
