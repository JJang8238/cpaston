<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
    <meta name="description" content="" />
    <meta name="author" content="" />
    <title>볼피또</title>

    <!-- Favicon-->
    <link rel="icon" type="image/x-icon" href="<%=request.getContextPath()%>/assets/favicon.ico" />

    <!-- Core theme CSS (includes Bootstrap) -->
    <link href="<%=request.getContextPath()%>/css/styles.css" rel="stylesheet" />
</head>
<body>
    <!-- Responsive navbar -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container px-5">
            <a class="navbar-brand" href="<%=request.getContextPath()%>/index.jsp">볼피또</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse"
                    data-bs-target="#navbarSupportedContent" aria-controls="navbarSupportedContent"
                    aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarSupportedContent">
                <ul class="navbar-nav ms-auto mb-2 mb-lg-0">
                    <li class="nav-item">
                        <a class="nav-link active" aria-current="page" href="<%=request.getContextPath()%>/index.jsp">홈</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="<%=request.getContextPath()%>/register.jsp">회원가입</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="<%=request.getContextPath()%>/login.jsp">로그인</a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <!-- Page Content -->
    <div class="container px-4 px-lg-5">
        <!-- Heading Row -->
        <div class="row gx-4 gx-lg-5 align-items-center my-5">
            <div class="col-lg-7">
                <img class="img-fluid rounded mb-4 mb-lg-0"
                     src="<%=request.getContextPath()%>/assets/img/football.png" alt="플랩풋볼 메인 이미지" />
            </div>
            <div class="col-lg-5">
                <h1 class="font-weight-light">우리의 운동 플랫폼</h1>
                <p>이 사이트는 경기 매칭, 커뮤니티, 리뷰 기능을 모두 제공합니다.</p>
                <a class="btn btn-primary" href="<%=request.getContextPath()%>/login.jsp">지금 참여하기</a>
            </div>
        </div>

        <!-- Call to Action -->
		<div class="my-5 p-3 bg-secondary text-white text-center rounded">
        심한 욕설, 불법 행위 등을 금지합니다.
   	 	</div>

        <!-- Content Row -->
    <div class="row text-center">
        <div class="col-md-4">
            <div class="card mb-3">
                <div class="card-body">
                    <h3>경기 매칭</h3>
                    <p>경기를 뛰고 싶을 때! 원하는 지역에서 매칭을 손쉽게!</p>
                    <a href="#" class="btn btn-primary">자세히 보기</a>
                </div>
            </div>
        </div>
 		<div class="col-md-4">
           		 <div class="card mb-3">
                		<div class="card-body">
                    		<h3>커뮤니티</h3>
                   		 <p>같은 관심사를 가진 사람들과 소통 또는 모임을 만들어요.</p>
                   		 <a href="#" class="btn btn-primary">자세히 보기</a>
               			</div>
            	</div>
        </div>
		<div class="col-md-4">
            		<div class="card mb-3">
                		<div class="card-body">
                    		<h3>리뷰</h3>
                    		<p>참여했던 경기, 모임에 대해 자유롭게 리뷰하고 평가할 수 있어요.</p>
                    		<a href="#" class="btn btn-primary">자세히 보기</a>
                		</div>
            		</div>
       		 	</div>
    		</div>
		</div>

    <!-- Footer -->
    <footer class="py-5 bg-dark">
        <div class="container px-4 px-lg-5">
            <p class="m-0 text-center text-white">Copyright &copy; 볼피또 2025</p>
        </div>
    </footer>

    <!-- Bootstrap core JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
    <!-- Core theme JS -->
    <script src="<%=request.getContextPath()%>/js/scripts.js"></script>
</body>
</html>
