function(project_fetch_git project_name git_repository git_tag)
	FetchContent_Declare(
		${project_name}
		GIT_REPOSITORY ${git_repository}
		GIT_TAG ${git_tag}
	)
	FetchContent_MakeAvailable(${project_name})
endfunction()