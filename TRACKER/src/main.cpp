#include "../include/imgui.h"
#include "../include/imgui-SFML.h"

#include "../include/ayumi.h"

//#include <SFML/Graphics.hpp>

#include <SFML/Graphics/RenderWindow.hpp>
#include <SFML/System/Clock.hpp>
#include <SFML/Window/Event.hpp>
#include <SFML/Graphics/CircleShape.hpp>

#include <cstring>
#include <string>
#include <sstream>

//////////////////////////////////
// DEFINES AND NEEDED VALUES    //
//////////////////////////////////

//   C - 0, C# - 1, D - 2, D# - 3, E - 4, F - 5, F# - 6, G - 7, G# - 8, A - 9, A# - 10, B - 11 ;
int TunesTable[8][12] = {
    // OCTAVE -3,
        {   3822, 3608, 3405, 3214, 3034, 2863, 2703, 2551, 2408, 2273, 2145, 2025  },
    // OCTAVE -2,
        {   1911, 1804, 1703, 1607, 1517, 1432, 1351, 1276, 1204, 1136, 1073, 1012  },
    // OCTAVE -1,
        {   956, 902, 851, 804, 758, 716, 676, 638, 602, 568, 536, 506  },
    // OCTAVE 0
        {   478, 451, 426, 402, 379, 358, 338, 319, 301, 284, 268, 253  },
    // OCTAVE 1
        {   239, 225, 213, 201, 190, 179, 169, 159, 150, 142, 134, 127  },
    // OCTAVE 2
        {   119, 113, 106, 100, 95, 89, 84, 80, 75, 71, 67, 63  },
    // OCTAVE 3
        {   60, 56, 53, 50, 47, 45, 42, 40, 38, 36, 34, 32  },
    // OCTAVE 4
        {   30, 28, 27, 25, 24, 22, 21, 20, 19, 18, 17, 16  }
};


#define TONE_CHARS       3
#define INSTR_CHARS      2
#define VOLUME_CHARS     1

#define TONE_LENGTH      TONE_CHARS+1
#define INSTR_LENGTH     INSTR_CHARS+1
#define VOLUME_LENGTH    VOLUME_CHARS+1

#define CELL_SIZE 10

#define TONE_CELL_SIZE      CELL_SIZE * TONE_CHARS
#define INSTR_CELL_SIZE     CELL_SIZE * INSTR_CHARS
#define VOLUME_CELL_SIZE    CELL_SIZE * VOLUME_CHARS

#define GRID_ROWS 32

#define INSTR_NAME_LENGTH   50
#define INSTR_FRAMES_LENGTH 32

//////////////////////////////
// STRUCT IMPLEMENTATIONS   //
//////////////////////////////
struct TGridItem {
    char tone[TONE_LENGTH];
    char instr[INSTR_LENGTH];
    char volume[VOLUME_LENGTH];


    TGridItem() {}
};

struct TPattern {
    TGridItem memory[GRID_ROWS*3];

    TPattern() {
        for(int i = 0; i < GRID_ROWS*3; i++) {
            memory[i].tone[0]    = 'A';
            memory[i].tone[1]    = '-';
            memory[i].tone[2]    = '0';
            memory[i].tone[3]    = '\0';
            memory[i].instr[0]   = '0';
            memory[i].instr[1]   = '0';
            memory[i].instr[2]   = '\0';
            memory[i].volume[0]  = 'F';
            memory[i].volume[1]  = '\0';
        }
    }
};

struct TPatternsCollection {
    private:
        std::vector<TPattern> collection;
        int currentPattern;
        int nPatterns;

    public:
        TPatternsCollection() {
            collection.push_back(TPattern());

            currentPattern  = 0;
            nPatterns       = 1;
        }

        int Size() {
            return nPatterns;
        }

        void NewPattern() {
            collection.push_back(TPattern());
            currentPattern = nPatterns;
            ++nPatterns;
        }

        void DeletePattern(int idx) {
            if(nPatterns > 1) {
                collection.erase(collection.begin() + idx);
                --nPatterns;
                currentPattern = 0;
            }
        }

        TPattern* GetCurrentPattern() {
            return &collection[currentPattern];
        }

        int CurrentPatern() {
            return currentPattern;
        }

        void TInstrumentsCollection(int newPattern) {
            currentPattern = newPattern;
        }
};

int nextInstrumentID = 1;
struct TInstrument {
    int     ID;
    char    *name;
    bool    repeat;
    int     lastFrame;
    std::vector<bool>    activeFrames;
    std::vector<int>     volumeFrames;
    std::vector<int>     noiseFrames;

    TInstrument() {
        ID              = nextInstrumentID++;
        name            = "MyInstrument";
        repeat          = false;
        lastFrame       = 0;

        activeFrames    = std::vector<bool>(INSTR_FRAMES_LENGTH,    true);
        volumeFrames    = std::vector<int>(INSTR_FRAMES_LENGTH,     15);
        noiseFrames     = std::vector<int>(INSTR_FRAMES_LENGTH,     0);
    }
};

struct TInstrumentsCollection {
    private:
        std::vector<TInstrument> collection;
        int currentInstrument;
        int nInstruments;

    public:

        TInstrumentsCollection() {
            collection.push_back(TInstrument());

            currentInstrument  = 0;
            nInstruments       = 1;
        }

        int Size() {
            return nInstruments;
        }

        void NewInstrument() {
            collection.push_back(TInstrument());
            currentInstrument = nInstruments;
            ++nInstruments;
        }

        void DeleteInstrument(int idx) {
            if(nInstruments > 1) {
                collection.erase(collection.begin() + idx);
                --nInstruments;
                currentInstrument = 0;
            }
        }

        TInstrument* GetCurrentInstrument() {
            return &collection[currentInstrument];
        }

        TInstrument* GetInstrument(int idx) {
            if(idx >= 0 && idx < nInstruments)
                return &collection[idx];
            else
                return NULL;
        }

        int CurrentInstrument() {
            return currentInstrument;
        }

        void SetCurrentInstrument(int newInstrument) {
            currentInstrument = newInstrument;
        }
};


//////////////////////////////
// FORWARD DECLARATIONS     //
//////////////////////////////
void PrintInstrumentsWorkspace();
void PrintInstrumentsGrid();
void PrintInstrumentEditor();
void PrintPatternsGrid();
void PrintWorkingGrid();
void ReadKeyboard();

ImGuiIO&    io = ImGui::GetIO();
struct      ayumi ay_emu;

TPatternsCollection     patterns;
TInstrumentsCollection  instruments;

//////////////////////////////
//      MAIN FUNCTION       //
//////////////////////////////
int main() {
    bool show_demo_window = true;
    sf::RenderWindow window(sf::VideoMode(640, 480), "ImGui + SFML = <3");
    window.setFramerateLimit(60);
    ImGui::SFML::Init(window);

    io.AddInputCharactersUTF8("<azsxcfvgbhnmk,l.q2w3e4rt6y7ui9o0p");

    ImGuiStyle * style = &ImGui::GetStyle();

    sf::CircleShape shape(100.f);
    shape.setFillColor(sf::Color::Green);
    sf::Clock deltaClock;

    // AYUMI emulator
    ayumi_configure(&ay_emu, true, 2000000, 44100); // 3,3 MHz



    while (window.isOpen()) {
        sf::Event event;
        while (window.pollEvent(event)) {
            ImGui::SFML::ProcessEvent(event);

            if (event.type == sf::Event::Closed) {
                window.close();
            }
        }

        ImGui::SFML::Update(window, deltaClock.restart());

        PrintInstrumentsWorkspace();
        PrintPatternsGrid();
        PrintWorkingGrid();


        ImGui::ShowDemoWindow(&show_demo_window);

        window.clear();
        ImGui::SFML::Render(window);
        window.display();
    }

    ImGui::SFML::Shutdown();
}


//////////////////////////////
// FUNCTIONS IMPLEMENTATION //
//////////////////////////////
void PrintWorkingGrid() {

    TGridItem *memory       = patterns.GetCurrentPattern()->memory;
    std::string channel     = "";
    std::string auxLabel    = "";
    bool readKB             = false;

    ImGui::BeginChild("##header", ImVec2(0, ImGui::GetTextLineHeightWithSpacing()+ImGui::GetStyle().ItemSpacing.y));
    ImGui::Columns(3);
    ImGui::Text("Channel A"); ImGui::NextColumn();
    ImGui::Text("Channel B"); ImGui::NextColumn();
    ImGui::Text("Channel C"); ImGui::NextColumn();
    ImGui::Columns(1);
    ImGui::Separator();
    ImGui::EndChild();
    ImGui::BeginChild("##scrollingregion", ImVec2(0, 1000));

    ImGui::Columns(3, NULL, true);
    for (int i = 0; i < GRID_ROWS; i++)
    {
        if (ImGui::GetColumnIndex() == 0) {
            ImGui::Separator();
        }

        for(int j = 0; j < 3; j++) {
            readKB = false;

            switch (j) {
                case 0: {   channel = "A";  break;  }
                case 1: {   channel = "B";  break;  }
                case 2: {   channel = "C";  break;  }
            }

            auxLabel = "##" + channel + std::to_string(i);

            // Tone input text
            ImGui::PushItemWidth(TONE_CELL_SIZE);
            ImGui::InputText((auxLabel + "t").c_str(), memory[(i*3)+j].tone,    TONE_LENGTH, ImGuiInputTextFlags_ReadOnly|ImGuiInputTextFlags_AutoSelectAll);
            ImGui::SameLine();
            if (ImGui::IsItemActive()) readKB = true;

            // Instrument input text
            ImGui::PushItemWidth(INSTR_CELL_SIZE);
            ImGui::InputText((auxLabel + "i").c_str(), memory[(i*3)+j].instr,   INSTR_LENGTH, ImGuiInputTextFlags_AutoSelectAll|ImGuiInputTextFlags_CharsDecimal);
            ImGui::SameLine();

            // Volume input text
            ImGui::PushItemWidth(VOLUME_CELL_SIZE+4);
            ImGui::InputText((auxLabel + "v").c_str(), memory[(i*3)+j].volume,  VOLUME_LENGTH, ImGuiInputTextFlags_AutoSelectAll|ImGuiInputTextFlags_CharsUppercase);

            if(readKB)  { ReadKeyboard(); }

            ImGui::NextColumn();
        }
    }

    ImGui::Columns(1);
    ImGui::Separator();
    ImGui::EndChild();
}

void PrintInstrumentsWorkspace() {
    ImGui::Columns(2);
    PrintInstrumentsGrid();
    ImGui::NextColumn();
    PrintInstrumentEditor();
    ImGui::Columns(1);
    ImGui::Separator();
}

// struct TInstrument {
//     int     ID;
//     char    *name;
//     bool    repeat;
//     int     lastFrame;
//     std::vector<bool>    activeFrames;
//     std::vector<int>     volumeFrames;
//     std::vector<int>     noiseFrames;
// 
//     TInstrument() {
//         ID              = nextInstrumentID++;
//         name            = "MyInstrument";
//         repeat          = false;
//         lastFrame       = 0;
// 
//         activeFrames    = std::vector<bool>(true,   INSTR_FRAMES_LENGTH);
//         volumeFrames    = std::vector<int>(15,      INSTR_FRAMES_LENGTH);
//         noiseFrames     = std::vector<int>(0,       INSTR_FRAMES_LENGTH);
//     }
// };

#define BUTTON_MAX_HEIGTH   80
#define BUTTON_MAX_WIDTH    20
#define MAX_VOLUME          15
std::string debugStr    = "";
std::string subStr    = "";

float values[INSTR_FRAMES_LENGTH];

void PrintInstrumentEditor() {
    TInstrument * instr = instruments.GetCurrentInstrument();
    static char buffer[INSTR_FRAMES_LENGTH*3];


    ImGui::BeginChild("##instrumentsscrollingregion", ImVec2(1000, 300), true, ImGuiWindowFlags_HorizontalScrollbar);

    ImGui::PlotHistogram("Histogram", values, IM_ARRAYSIZE(values), 0, NULL, 0, 15, ImVec2(BUTTON_MAX_WIDTH*INSTR_FRAMES_LENGTH,BUTTON_MAX_HEIGTH));

    if(ImGui::InputText("##volumeinput", buffer, IM_ARRAYSIZE(buffer))) {
        std::string strBuffer = buffer;
        std::istringstream iss(strBuffer);

        int frame   = 0;
        debugStr    = "";
        debugStr = "Instr " + std::to_string(instr->ID) + " - ";
        while(iss && frame < INSTR_FRAMES_LENGTH) {
            subStr = "";
            iss >> subStr;
            if(!subStr.empty()) {
                debugStr = debugStr + "[" + std::to_string(frame) + "," + std::to_string(std::stoi(subStr, nullptr)) + "]: " + std::to_string((float)instr->volumeFrames[frame]) + " ";
                instr->volumeFrames[frame++] = std::stoi(subStr, nullptr);
            }
        }

        for(int i = 0; i < INSTR_FRAMES_LENGTH; i++)
            values[i] = (float)instr->volumeFrames[i];

    }
    ImGui::TextUnformatted(debugStr.c_str());


//    for(int i = 0; i < INSTR_FRAMES_LENGTH; i++) {
//        buttName = std::to_string(instr->volumeFrames[i]) + "##vol" + std::to_string(i);
//        buttHeight = ((float)instr->volumeFrames[i]/MAX_VOLUME)*BUTTON_MAX_HEIGTH;
//        clicked = false;
//
//
//        buttonPos   = ImGui::GetCursorPosY();
////        ImGui::PushStyleColor(ImGuiCol_::ImGuiCol_Button, ImVec4(0, 0, 0, 255));
////        if(ImGui::Button(("##N"+std::to_string(i)).c_str(), ImVec2(BUTTON_MAX_WIDTH, BUTTON_MAX_HEIGTH - buttHeight))) {
////            mousePos    = ImGui::GetMousePos();
////            clicked     = true;
////        }
////        ImGui::PopStyleColor();
//
//        ImGui::PushStyleColor(ImGuiCol_::ImGuiCol_Button, ImVec4(0, 0, 204, 255));
//        if(ImGui::Button((buttName+"B").c_str(), ImVec2(BUTTON_MAX_WIDTH, buttHeight))) {
//            mousePos    = ImGui::GetMousePos();
//            clicked     = true;
//        }
//        ImGui::PopStyleColor();
//
//        if(clicked) {
//            float distance = std::abs(buttonPos - mousePos.y);
//
//            //instr->volumeFrames[i] = (int) (distance/BUTTON_MAX_HEIGTH)*MAX_VOLUME;
//            msg = "Modified frame " + std::to_string(i) + " to " + std::to_string(instr->volumeFrames[i])
//            + "; Distance=" + std::to_string(distance) + "; Button Height=" + std::to_string(buttHeight);
//        }
//        ImGui::SameLine();
//    }

    

    ImGui::EndChild();


// ImGuiCol_Button
// PushStyleColor(ImGuiCol idx, ImU32 col);
// PushStyleColor(ImGuiCol idx, const ImVec4& col);
// PopStyleColor(int count = 1);
// Button(const char* label, const ImVec2& size = ImVec2(0,0));
    // ImGui::PlotHistogram(const char* label, const float* values, int values_count, int values_offset = 0, const char* overlay_text = NULL, float scale_min = FLT_MAX, float scale_max = FLT_MAX, ImVec2 graph_size = ImVec2(0,0), int stride = sizeof(float));
    // ImGui::PlotHistogram("Histogram", values, IM_ARRAYSIZE(values), 20, NULL, 0, 15, ImVec2(1000,80));
    //void PlotHistogram("volumeHist", const float *values, int values_count, int values_offset = 0, const char* overlay_text = NULL, float scale_min = FLT_MAX, float scale_max = FLT_MAX, ImVec2 graph_size = ImVec2(0,0), int stride = sizeof(float));
}

void PrintPatternsGrid() {
    if(ImGui::SmallButton("Add Pattern")) {
        patterns.NewPattern();
    }

    for(int i = 0; i < patterns.Size(); i++) {  
        
        if(ImGui::SmallButton(("Pattern " + std::to_string(i)).c_str())) {
            patterns.TInstrumentsCollection(i);
        }
        ImGui::SameLine();
        
        if(ImGui::SmallButton(("Delete##P" + std::to_string(i)).c_str())) {
            patterns.DeletePattern(i);
        }
    }
}

void PrintInstrumentsGrid() {
    if(ImGui::SmallButton("Add Instrument")) {
        instruments.NewInstrument();
    }

    for(int i = 0; i < instruments.Size(); i++) {
        TInstrument *instr      = instruments.GetInstrument(i);

        std::string instrName   = "" + std::to_string(instr->ID) + " - " + instr->name;
        if(ImGui::SmallButton(instrName.c_str())) {
            instruments.SetCurrentInstrument(i);
        }
        ImGui::SameLine();
        
        if(ImGui::SmallButton(("Delete##I" + std::to_string(instr->ID)).c_str())) {
            instruments.DeleteInstrument(i);
        }
    }
}

#define Z_KEY_ID        25      // C
#define S_KEY_ID        18      // C#
#define X_KEY_ID        23      // D
#define D_KEY_ID        3       // D#
#define C_KEY_ID        2       // E
#define V_KEY_ID        21      // F
#define G_KEY_ID        6       // F#
#define B_KEY_ID        1       // G
#define H_KEY_ID        7       // G#
#define N_KEY_ID        13      // A
#define J_KEY_ID        9       // A#
#define M_KEY_ID        12      // B

#define Q_KEY_ID        16      // C    +1 Octave
#define TWO_KEY_ID      28      // C#   +1 Octave
#define W_KEY_ID        22      // D    +1 Octave
#define THREE_KEY_ID    29      // D#   +1 Octave
#define E_KEY_ID        4       // E    +1 Octave
#define R_KEY_ID        17      // F    +1 Octave
#define FIVE_KEY_ID     31      // F#   +1 Octave
#define T_KEY_ID        19      // G    +1 Octave
#define SIX_KEY_ID      32      // G#   +1 Octave
#define Y_KEY_ID        24      // A    +1 Octave
#define SEVEN_KEY_ID    33      // A#   +1 Octave
#define U_KEY_ID        20      // B    +1 Octave

#define I_KEY_ID        8       // C    +2 Octave
#define NINE_KEY_ID     35      // C#   +2 Octave
#define O_KEY_ID        14      // D    +2 Octave
#define ZERO_KEY_ID     26      // D#   +2 Octave

#define CHANNEL_A   0
#define CHANNEL_B   1
#define CHANNEL_C   2

void ReadKeyboard() {
    bool    pressed = true;
    int     period  = 0;
    int     octave  = 3;
    if      (io.KeysDownDuration[Z_KEY_ID] >= 0.0f)     {   period = TunesTable[octave][0]; ImGui::SameLine();  ImGui::Text("%d (%.02f secs) period: %d", Z_KEY_ID, io.KeysDownDuration[Z_KEY_ID], TunesTable[octave][0]);     }
    else if (io.KeysDownDuration[S_KEY_ID] >= 0.0f)     {   period = TunesTable[octave][1];     }
    else if (io.KeysDownDuration[X_KEY_ID] >= 0.0f)     {   period = TunesTable[octave][2];     }
    else if (io.KeysDownDuration[D_KEY_ID] >= 0.0f)     {   period = TunesTable[octave][3];     }
    else if (io.KeysDownDuration[C_KEY_ID] >= 0.0f)     {   period = TunesTable[octave][4];     }
    else if (io.KeysDownDuration[V_KEY_ID] >= 0.0f)     {   period = TunesTable[octave][5];     }
    else if (io.KeysDownDuration[G_KEY_ID] >= 0.0f)     {   period = TunesTable[octave][6];     }
    else if (io.KeysDownDuration[B_KEY_ID] >= 0.0f)     {   period = TunesTable[octave][7];     }
    else if (io.KeysDownDuration[H_KEY_ID] >= 0.0f)     {   period = TunesTable[octave][8];     }
    else if (io.KeysDownDuration[N_KEY_ID] >= 0.0f)     {   period = TunesTable[octave][9];     }
    else if (io.KeysDownDuration[J_KEY_ID] >= 0.0f)     {   period = TunesTable[octave][10];    }
    else if (io.KeysDownDuration[M_KEY_ID] >= 0.0f)     {   period = TunesTable[octave][11];    }
    else {  pressed = false;    }

    if(!pressed && octave < 7) {
        pressed = true;
        if  (    io.KeysDownDuration[Q_KEY_ID] >= 0.0f)     {   period = TunesTable[octave+1][0];   }
        else if (io.KeysDownDuration[TWO_KEY_ID] >= 0.0f)   {   period = TunesTable[octave+1][1];   }
        else if (io.KeysDownDuration[W_KEY_ID] >= 0.0f)     {   period = TunesTable[octave+1][2];   }
        else if (io.KeysDownDuration[THREE_KEY_ID] >= 0.0f) {   period = TunesTable[octave+1][3];   }
        else if (io.KeysDownDuration[E_KEY_ID] >= 0.0f)     {   period = TunesTable[octave+1][4];   }
        else if (io.KeysDownDuration[R_KEY_ID] >= 0.0f)     {   period = TunesTable[octave+1][5];   }
        else if (io.KeysDownDuration[FIVE_KEY_ID] >= 0.0f)  {   period = TunesTable[octave+1][6];   }
        else if (io.KeysDownDuration[T_KEY_ID] >= 0.0f)     {   period = TunesTable[octave+1][7];   }
        else if (io.KeysDownDuration[SIX_KEY_ID] >= 0.0f)   {   period = TunesTable[octave+1][8];   }
        else if (io.KeysDownDuration[Y_KEY_ID] >= 0.0f)     {   period = TunesTable[octave+1][9];   }
        else if (io.KeysDownDuration[SEVEN_KEY_ID] >= 0.0f) {   period = TunesTable[octave+1][10];  }
        else if (io.KeysDownDuration[U_KEY_ID] >= 0.0f)     {   period = TunesTable[octave+1][11];  }
        else {  pressed = false;    }
    }

    if(!pressed && octave < 6) {
        pressed = true;
        if      (io.KeysDownDuration[I_KEY_ID] >= 0.0f)     {   period = TunesTable[octave+2][0];   }
        else if (io.KeysDownDuration[NINE_KEY_ID] >= 0.0f)  {   period = TunesTable[octave+2][1];   }
        else if (io.KeysDownDuration[O_KEY_ID] >= 0.0f)     {   period = TunesTable[octave+2][2];   }
        else if (io.KeysDownDuration[ZERO_KEY_ID] >= 0.0f)  {   period = TunesTable[octave+2][3];   }
        else {  pressed = false;    }
    }

    if(pressed) {
        ayumi_set_pan(&ay_emu, CHANNEL_A, 0.5, true);
        ayumi_set_mixer(&ay_emu, CHANNEL_A, false, true, false);
        ayumi_set_volume(&ay_emu, CHANNEL_A, 15);
        ayumi_set_tone(&ay_emu, CHANNEL_A, period);
        ayumi_process(&ay_emu);
    }
}




// if      (io.KeysDownDuration[Z_KEY_ID] >= 0.0f)     {   ImGui::SameLine();  ImGui::Text("%d (%.02f secs)", Z_KEY_ID, io.KeysDownDuration[Z_KEY_ID]);            }
// else if (io.KeysDownDuration[S_KEY_ID] >= 0.0f)     {   ImGui::SameLine();  ImGui::Text("%d (%.02f secs)", S_KEY_ID, io.KeysDownDuration[S_KEY_ID]);            }
// else if (io.KeysDownDuration[X_KEY_ID] >= 0.0f)     {   ImGui::SameLine();  ImGui::Text("%d (%.02f secs)", X_KEY_ID, io.KeysDownDuration[X_KEY_ID]);            }
// else if (io.KeysDownDuration[D_KEY_ID] >= 0.0f)     {   ImGui::SameLine();  ImGui::Text("%d (%.02f secs)", D_KEY_ID, io.KeysDownDuration[D_KEY_ID]);            }
// else if (io.KeysDownDuration[C_KEY_ID] >= 0.0f)     {   ImGui::SameLine();  ImGui::Text("%d (%.02f secs)", C_KEY_ID, io.KeysDownDuration[C_KEY_ID]);            }
// else if (io.KeysDownDuration[V_KEY_ID] >= 0.0f)     {   ImGui::SameLine();  ImGui::Text("%d (%.02f secs)", V_KEY_ID, io.KeysDownDuration[V_KEY_ID]);            }
// else if (io.KeysDownDuration[G_KEY_ID] >= 0.0f)     {   ImGui::SameLine();  ImGui::Text("%d (%.02f secs)", G_KEY_ID, io.KeysDownDuration[G_KEY_ID]);            }
// else if (io.KeysDownDuration[B_KEY_ID] >= 0.0f)     {   ImGui::SameLine();  ImGui::Text("%d (%.02f secs)", B_KEY_ID, io.KeysDownDuration[B_KEY_ID]);            }
// else if (io.KeysDownDuration[H_KEY_ID] >= 0.0f)     {   ImGui::SameLine();  ImGui::Text("%d (%.02f secs)", H_KEY_ID, io.KeysDownDuration[H_KEY_ID]);            }
// else if (io.KeysDownDuration[N_KEY_ID] >= 0.0f)     {   ImGui::SameLine();  ImGui::Text("%d (%.02f secs)", N_KEY_ID, io.KeysDownDuration[N_KEY_ID]);            }
// else if (io.KeysDownDuration[J_KEY_ID] >= 0.0f)     {   ImGui::SameLine();  ImGui::Text("%d (%.02f secs)", J_KEY_ID, io.KeysDownDuration[J_KEY_ID]);            }
// else if (io.KeysDownDuration[M_KEY_ID] >= 0.0f)     {   ImGui::SameLine();  ImGui::Text("%d (%.02f secs)", M_KEY_ID, io.KeysDownDuration[M_KEY_ID]);            }
// 
// else if (io.KeysDownDuration[Q_KEY_ID] >= 0.0f)     {   ImGui::SameLine();  ImGui::Text("%d (%.02f secs)", Q_KEY_ID, io.KeysDownDuration[Q_KEY_ID]);            }
// else if (io.KeysDownDuration[TWO_KEY_ID] >= 0.0f)   {   ImGui::SameLine();  ImGui::Text("%d (%.02f secs)", TWO_KEY_ID, io.KeysDownDuration[TWO_KEY_ID]);        }
// else if (io.KeysDownDuration[W_KEY_ID] >= 0.0f)     {   ImGui::SameLine();  ImGui::Text("%d (%.02f secs)", W_KEY_ID, io.KeysDownDuration[W_KEY_ID]);            }
// else if (io.KeysDownDuration[THREE_KEY_ID] >= 0.0f) {   ImGui::SameLine();  ImGui::Text("%d (%.02f secs)", THREE_KEY_ID, io.KeysDownDuration[THREE_KEY_ID]);    }
// else if (io.KeysDownDuration[E_KEY_ID] >= 0.0f)     {   ImGui::SameLine();  ImGui::Text("%d (%.02f secs)", E_KEY_ID, io.KeysDownDuration[E_KEY_ID]);            }
// else if (io.KeysDownDuration[R_KEY_ID] >= 0.0f)     {   ImGui::SameLine();  ImGui::Text("%d (%.02f secs)", R_KEY_ID, io.KeysDownDuration[R_KEY_ID]);            }
// else if (io.KeysDownDuration[FIVE_KEY_ID] >= 0.0f)  {   ImGui::SameLine();  ImGui::Text("%d (%.02f secs)", FIVE_KEY_ID, io.KeysDownDuration[FIVE_KEY_ID]);      }
// else if (io.KeysDownDuration[T_KEY_ID] >= 0.0f)     {   ImGui::SameLine();  ImGui::Text("%d (%.02f secs)", T_KEY_ID, io.KeysDownDuration[T_KEY_ID]);            }
// else if (io.KeysDownDuration[SIX_KEY_ID] >= 0.0f)   {   ImGui::SameLine();  ImGui::Text("%d (%.02f secs)", SIX_KEY_ID, io.KeysDownDuration[SIX_KEY_ID]);        }
// else if (io.KeysDownDuration[Y_KEY_ID] >= 0.0f)     {   ImGui::SameLine();  ImGui::Text("%d (%.02f secs)", Y_KEY_ID, io.KeysDownDuration[Y_KEY_ID]);            }
// else if (io.KeysDownDuration[SEVEN_KEY_ID] >= 0.0f) {   ImGui::SameLine();  ImGui::Text("%d (%.02f secs)", SEVEN_KEY_ID, io.KeysDownDuration[SEVEN_KEY_ID]);    }
// else if (io.KeysDownDuration[U_KEY_ID] >= 0.0f)     {   ImGui::SameLine();  ImGui::Text("%d (%.02f secs)", U_KEY_ID, io.KeysDownDuration[U_KEY_ID]);            }
// 
// else if (io.KeysDownDuration[I_KEY_ID] >= 0.0f)     {   ImGui::SameLine();  ImGui::Text("%d (%.02f secs)", I_KEY_ID, io.KeysDownDuration[I_KEY_ID]);            }
// else if (io.KeysDownDuration[NINE_KEY_ID] >= 0.0f)  {   ImGui::SameLine();  ImGui::Text("%d (%.02f secs)", NINE_KEY_ID, io.KeysDownDuration[NINE_KEY_ID]);      }
// else if (io.KeysDownDuration[O_KEY_ID] >= 0.0f)     {   ImGui::SameLine();  ImGui::Text("%d (%.02f secs)", O_KEY_ID, io.KeysDownDuration[O_KEY_ID]);            }
// else if (io.KeysDownDuration[ZERO_KEY_ID] >= 0.0f)  {   ImGui::SameLine();  ImGui::Text("%d (%.02f secs)", ZERO_KEY_ID, io.KeysDownDuration[ZERO_KEY_ID]);      }