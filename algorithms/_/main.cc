#include "_.hh"

void sep (std::ofstream& o, Faces& objs, double scale);
int center (const Face& pt, double scale);

typedef std::vector<std::string> Algos;
typedef std::vector<void(*)(const std::string&,double)> Inits;
typedef std::vector<void(*)(cv::Mat&,Faces&,double)> Finds;
typedef std::vector<void(*)()> Stops;


int
main (int argc, const char* argv[])
{
    if (argc -1 != 4)
        return 1;
    auto cascade_name = argv[1];
    auto scale = std::stod(argv[2]);
    auto inFile = argv[3];
    auto outFile = argv[4];

    // ALGOS
    Algos algos = {/*"dbt",*/    "haar"};
    Inits inits = {/*dbt_init,*/ haar_init};
    Finds finds = {/*dbt_find,*/ haar_find};
    Stops stops = {/*dbt_stop,*/ haar_stop};

    for (auto i = 0; i < algos.size(); ++i)
    {
        auto tsvFile = outFile + algos[i];
        std::ofstream out(tsvFile);
        if (!out) {
            std::cerr << "!open " << tsvFile << std::endl;
            return 2;
        }

        cv::VideoCapture video;
        if (!video.open(inFile)) {
            std::cerr << "!load " << inFile << std::endl;
            return 2;
        }

        inits[i](cascade_name, scale);

        size_t N;
        cv::Mat frame;
        Faces objects;
        for (N = 1; ; ++N) {
            video >> frame;
            if (frame.empty())
                break;

            auto s = std::chrono::high_resolution_clock::now();
            finds[i](frame, objects, scale);
            auto f = std::chrono::high_resolution_clock::now();
            auto l = std::chrono::duration_cast<std::chrono::nanoseconds>(f-s);

            out << N << '\t' << l.count() << '\t';
            sep(out, objects, scale);
            out << '\n';
            objects.clear();
        }

        stops[i]();
        out.close();
        std::cout << algos[i] << ' ' << N << std::endl;
    }

    return 0;
}



void
sep (std::ofstream& o, Faces& objs, double scale) {
    bool first = true;
    for (const auto& obj : objs) {
        if (first)
            first = false;
        else
            o << ',';
        o << center(obj, scale);
    }
}

int
center (const Face& pt, double scale) {
    auto x = pt.x + 0.5 * pt.width;
    auto y = pt.y + 0.5 * pt.height;
    return x * x + y * y;
}
