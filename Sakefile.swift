import SakefileDescription

Sake {
    $0.task(name: "build", description: "xxx", action: { (_) in
        print("wooorks")
    })
}.run()

