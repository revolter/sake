import SakefileDescription

func something() {
    Sake {
        $0.task(name: "build", description: "xxx", action: { (xxx) in
            print("wooorks")
            throw "xxxx"
        })
    }.run()
}


